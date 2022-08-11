//
//  LoginViewModelTests.swift
//  PresentationTests
//
//  Created by Benjamin Mecanović on 11.08.2022..
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
import RxBlocking
import Domain
@testable import Presentation

class LoginViewModelTests: XCTestCase {
    func test_inputOutputValidation() {
        let scheduler = TestScheduler(initialClock: 0)
        let emailErrorMessage = MisformattedEmailError().localizedDescription
        let passwordErrorMessage = MisformattedPasswordError().localizedDescription
        let sut = makeSUT()

        let emailValues = scheduler.createHotObservable([
            .next(100, ""),
            .next(300, "valid@email.com")
        ])
        .asDriver(onErrorDriveWith: .empty())

        let passwordValues = scheduler.createHotObservable([
            .next(200, ""),
            .next(400, "12345$")
        ])
        .asDriver(onErrorDriveWith: .empty())

        let input = LoginViewModel.Input(email: emailValues, password: passwordValues, loginTrigger: .empty())

        let output = sut.transform(input: input)

        let emailValidationResults = scheduler.record(source: output.emailValidation)
        let expectedEmailValidationResults = Recorded.events([
            .next(100, ValidationState.invalid(emailErrorMessage)),
            .next(300, .valid)
        ])

        let passwordValidationResults = scheduler.record(source: output.passwordValidation)
        let expectedPasswordValidationResults = Recorded.events([
            .next(200, ValidationState.invalid(passwordErrorMessage)),
            .next(400, .valid)
        ])

        let areInputsValidResults = scheduler.record(source: output.areInputsValid)
        let expectedAreInputsValidResults = Recorded.events([
            // Nothing should be @1 because of combineLatest
            .next(200, false),
            .next(300, false),
            .next(400, true)
        ])

        scheduler.start()

        XCTAssertEqual(emailValidationResults.events, expectedEmailValidationResults)
        XCTAssertEqual(passwordValidationResults.events, expectedPasswordValidationResults)
        XCTAssertEqual(areInputsValidResults.events, expectedAreInputsValidResults)
    }

    func test_loginStateOnSuccessfulLogin() throws {
        let scheduler = TestScheduler(initialClock: 0)
        let sut = makeSUT()

        let emailValues = scheduler.createHotObservable([
            .next(100, "valid@email.com")
        ])

        let passwordValues = scheduler.createHotObservable([
            .next(100, "12345$")
        ])

        let loginTrigger = scheduler.createHotObservable([
            .next(200, ())
        ])

        let input = LoginViewModel.Input(
            email: emailValues.asDriver(onErrorDriveWith: .empty()),
            password: passwordValues.asDriver(onErrorDriveWith: .empty()),
            loginTrigger: loginTrigger.asSignal(onErrorSignalWith: .empty())
        )

        let output = sut.transform(input: input)

        let result = scheduler.start(created: 0, subscribed: 0, disposed: 1000) {
            output.loginState
        }

        XCTAssertRecordedElements(result.events, [.initial, .loading, .loaded])
    }

    func test_loginStateOnFailedLogin() throws {
        let scheduler = TestScheduler(initialClock: 0)
        let errorMessage = RxError.unknown.localizedDescription
        let sut = makeSUT(useCase: MockLoginUserUseCase(shouldThrowError: true))

        let emailValues = scheduler.createHotObservable([
            .next(100, "valid@email.com")
        ])

        let passwordValues = scheduler.createHotObservable([
            .next(100, "12345$")
        ])

        let loginTrigger = scheduler.createHotObservable([
            .next(200, ())
        ])

        let input = LoginViewModel.Input(
            email: emailValues.asDriver(onErrorDriveWith: .empty()),
            password: passwordValues.asDriver(onErrorDriveWith: .empty()),
            loginTrigger: loginTrigger.asSignal(onErrorSignalWith: .empty())
        )

        let output = sut.transform(input: input)

        let result = scheduler.start(created: 0, subscribed: 0, disposed: 1000) {
            output.loginState
        }

        XCTAssertRecordedElements(result.events, [.initial, .loading, .failed(errorMessage)])
    }
}

extension LoginViewModelTests {
    /**
     System Under Test
     */
    func makeSUT(useCase: LoginUserUseCase = MockLoginUserUseCase()) -> LoginViewModel {
        let emailValidator = BasicEmailValidator().eraseToAnyValidator
        let passwordValidator = BasicPasswordValidator().eraseToAnyValidator
        let sut = LoginViewModel(
            loginUserUseCase: useCase,
            emailValidator: emailValidator,
            passwordValidator: passwordValidator
        )

        return sut
    }
}
