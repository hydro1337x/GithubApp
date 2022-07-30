//
//  ActivityTracker.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation
import RxSwift
import RxCocoa

final class ActivityTracker: SharedSequenceConvertibleType {
    public typealias Element = Bool
    public typealias SharingStrategy = DriverSharingStrategy

    private let lock = NSRecursiveLock()
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let isLoading: SharedSequence<SharingStrategy, Bool>

    public init() {
        isLoading = isLoadingRelay.asDriver()
            .distinctUntilChanged()
    }

    fileprivate func trackActivityOfObservable<O: ObservableConvertibleType>(_ source: O) -> Observable<O.Element> {
        return source.asObservable()
            .do(onNext: { _ in
                self.stopLoading()
            }, onError: { _ in
                self.stopLoading()
            }, onCompleted: {
                self.stopLoading()
            }, onSubscribe: startLoading)
    }

    private func startLoading() {
        lock.lock()
        isLoadingRelay.accept(true)
        lock.unlock()
    }

    private func stopLoading() {
        lock.lock()
        isLoadingRelay.accept(false)
        lock.unlock()
    }

    public func asSharedSequence() -> SharedSequence<SharingStrategy, Element> {
        return isLoading
    }
}

extension ObservableConvertibleType {
    func trackActivity(_ activityTracker: ActivityTracker) -> Observable<Element> {
        return activityTracker.trackActivityOfObservable(self)
    }
}
