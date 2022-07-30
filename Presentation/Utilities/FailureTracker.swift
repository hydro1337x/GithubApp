//
//  FailureTracker.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation
import RxSwift
import RxCocoa

final class FailureTracker: SharedSequenceConvertibleType {
    typealias SharingStrategy = DriverSharingStrategy
    private let failureSubject = PublishSubject<Error>()

    deinit {
        failureSubject.onCompleted()
    }

    fileprivate func trackFailure<O: ObservableConvertibleType>(from source: O) -> Observable<O.Element> {
        return source.asObservable().do(onError: handleOnError)
    }

    private func handleOnError(_ error: Error) {
        failureSubject.onNext(error)
    }

    public func asSharedSequence() -> SharedSequence<SharingStrategy, Error> {
        return failureSubject.asDriver(onErrorDriveWith: .empty())
    }

    public func asObservable() -> Observable<Error> {
        return failureSubject.asObservable()
    }
}

extension ObservableConvertibleType {
    func trackFailure(_ failureTracker: FailureTracker) -> Observable<Element> {
        return failureTracker.trackFailure(from: self)
    }
}
