//
//  MockLoginUserUseCase.swift
//  PresentationTests
//
//  Created by Benjamin Mecanović on 11.08.2022..
//

import RxSwift
import Domain

final class MockLoginUserUseCase: LoginUserUseCase {
    let shouldThrowError: Bool

    init(shouldThrowError: Bool = false) {
        self.shouldThrowError = shouldThrowError
    }

    func execute(input: LoginUserInput) -> Completable {
        shouldThrowError ? .error(RxError.unknown) : .empty()
    }
}
