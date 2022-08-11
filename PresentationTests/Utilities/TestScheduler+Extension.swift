//
//  TestScheduler+Extension.swift
//  PresentationTests
//
//  Created by Benjamin Mecanović on 11.08.2022..
//

import RxSwift
import RxTest

extension TestScheduler {
    func record<Source: ObservableConvertibleType>(source: Source) -> TestableObserver<Source.Element> {
        let observer = self.createObserver(Source.Element.self)
        let disposable = source.asObservable().bind(to: observer)
        self.scheduleAt(100000) {
            disposable.dispose()
        }
        return observer
    }
}
