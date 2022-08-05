//
//  LoginViewModel.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 04.08.2022..
//

import Foundation
import Domain
import RxSwift
import RxCocoa

public final class LoginViewModel {

    struct Input {
        let email: Driver<String>
        let password: Driver<String>
        let repeatedPassword: Driver<String>
        let loginTap: Signal<Void>
    }

    struct Output {
        let emailValidation: Driver<ValidationState>
        let passwordValidation: Driver<ValidationState>
        let repeatedPasswordValidation: Driver<ValidationState>
        let passwordsMatchValidation: Driver<ValidationState>
        let areInputsValid: Driver<Bool>
        let state: Driver<LoginState>
    }

    private let loginUserUseCase: LoginUserUseCase
    private let emailValidator: AnyValidator<String>
    private let passwordValidator: AnyValidator<String>
    private let passwordsMatchingValidator: AnyValidator<PasswordsInput>

    public init(
        loginUserUseCase: LoginUserUseCase,
        emailValidator: AnyValidator<String>,
        passwordValidator: AnyValidator<String>,
        passwordsMatchingValidator: AnyValidator<PasswordsInput>
    ) {
        self.loginUserUseCase = loginUserUseCase
        self.emailValidator = emailValidator
        self.passwordValidator = passwordValidator
        self.passwordsMatchingValidator = passwordsMatchingValidator
    }

    func transform(input: Input) -> Output {

        let emailValidation = input.email
            .asObservable()
            .flatMapLatest { [unowned self] input in
                emailValidator.validate(input: input)
                    .andThen(.just(ValidationState.valid))
                    .materialize()
                    .map { event -> ValidationState in
                        switch event {
                        case .error(let error):
                            return ValidationState.invalid(error.localizedDescription)
                        case .next, .completed:
                            return ValidationState.valid
                        }
                    }
                    .distinctUntilChanged()
            }
            .share()
            .debug()
            .startWith(.empty)

        let passwordValidation = input.password
            .asObservable()
            .flatMapLatest { [unowned self] input in
                passwordValidator.validate(input: input)
                    .andThen(.just(ValidationState.valid))
                    .materialize()
                    .map { event -> ValidationState in
                        switch event {
                        case .error(let error):
                            return ValidationState.invalid(error.localizedDescription)
                        case .next, .completed:
                            return ValidationState.valid
                        }
                    }
                    .distinctUntilChanged()
            }
            .share()
            .startWith(.empty)

        let repeatedPasswordValidation = input.repeatedPassword
            .asObservable()
            .flatMapLatest { [unowned self] input in
                passwordValidator.validate(input: input)
                    .andThen(.just(ValidationState.valid))
                    .materialize()
                    .map { event -> ValidationState in
                        switch event {
                        case .error(let error):
                            return ValidationState.invalid(error.localizedDescription)
                        case .next, .completed:
                            return ValidationState.valid
                        }
                    }
                    .distinctUntilChanged()
            }
            .share()
            .startWith(.empty)

        let passwordsMatchValidation = Observable
            .combineLatest(
                input.password.asObservable(),
                input.repeatedPassword.asObservable()
            )
            .flatMapLatest { [unowned self] inputs -> Observable<ValidationState> in
                let input = PasswordsInput(password: inputs.0, repeatedPassword: inputs.1)
                return passwordsMatchingValidator.validate(input: input)
                    .andThen(.just(ValidationState.valid))
                    .materialize()
                    .map { event -> ValidationState in
                        switch event {
                        case .error(let error):
                            return ValidationState.invalid(error.localizedDescription)
                        case .next, .completed:
                            return ValidationState.valid
                        }
                    }
                    .distinctUntilChanged()
            }
            .share()
            .startWith(.empty)

        let areInputsValid = Observable
            .combineLatest(
                emailValidation.map { $0 == .valid },
                passwordValidation.map { $0 == .valid },
                repeatedPasswordValidation.map { $0 == .valid },
                passwordsMatchValidation.map { $0 == .valid }
            )
            .map { $0.0 && $0.1 && $0.2 && $0.3 }

        let login = input.loginTap
            .asObservable()
            .withLatestFrom(
                Observable.combineLatest(input.email.asObservable(), input.password.asObservable())
            )
            .flatMap { [unowned self] email, password -> Observable<LoginState> in
                let input = LoginUserInput(email: email, password: password)
                return loginUserUseCase.execute(input: input)
                    .andThen(Observable<LoginState>.just(.loaded))
                    .materialize()
                    .map { event in
                        switch event {
                        case .error(let error):
                            return .failed(error.localizedDescription)
                        case .next, .completed:
                            return .loaded
                        }
                    }
                    .distinctUntilChanged()
            }
            .share()

        let state = Observable
            .merge(
                input.loginTap.asObservable().map { LoginState.loading },
                login
            )
            .startWith(.initial)

        return Output(
            emailValidation: emailValidation.asDriver(onErrorDriveWith: .empty()),
            passwordValidation: passwordValidation.asDriver(onErrorDriveWith: .empty()),
            repeatedPasswordValidation: repeatedPasswordValidation.asDriver(onErrorDriveWith: .empty()),
            passwordsMatchValidation: passwordsMatchValidation.asDriver(onErrorDriveWith: .empty()),
            areInputsValid: areInputsValid.asDriver(onErrorDriveWith: .empty()),
            state: state.asDriver(onErrorDriveWith: .empty())
        )
    }
}
