//
//  AsyncImageViewModel.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 31.07.2022..
//

import Foundation
import RxSwift
import RxCocoa

final class AsyncImageViewModel {
    struct Input {
        let initialTrigger: Signal<Void>
        let retryTrigger: Signal<Void>
    }

    struct Output {
        let state: Driver<AsyncImageState>
    }

    private let imageConvertible: Observable<Data>

    init(with imageConvertible: Observable<Data>) {
        self.imageConvertible = imageConvertible
    }

    func transform(input: Input) -> Output {
        let failureTracker = FailureTracker()

        let data = Observable.merge(input.retryTrigger.asObservable(), input.initialTrigger.asObservable())
            .flatMapLatest { [weak self] _ -> Observable<Data?> in
                guard let self = self else { return .empty() }
                return self.imageConvertible
                    .map { data -> Data? in return data }
                    .trackFailure(failureTracker)
                    .catchAndReturn(nil)
            }
            .compactMap { $0 }
            .map { AsyncImageState.loaded($0) }

        let failure = failureTracker
            .asObservable()
            .map { _ in AsyncImageState.failed }


        let state = Observable.merge(data, failure)
            .startWith(.initial)
            .asDriver(onErrorDriveWith: .empty())

        return Output(state: state)
    }
}
