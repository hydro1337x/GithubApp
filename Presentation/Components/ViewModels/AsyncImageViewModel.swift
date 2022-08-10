//
//  AsyncImageViewModel.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 31.07.2022..
//

import Foundation
import RxSwift
import RxCocoa

public final class AsyncImageViewModel {
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
        let state = Observable.merge(input.retryTrigger.asObservable(), input.initialTrigger.asObservable())
            .flatMapLatest { [weak self] _ -> Observable<AsyncImageState> in
                guard let self = self else { return .empty() }

                return self.imageConvertible
                    .map { .loaded($0) }
                    .catch { error in
                        .just(.failed)
                    }
            }

        return Output(state: state.startWith(.initial).asDriver(onErrorDriveWith: .empty()))
    }
}
