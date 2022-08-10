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
        let loginTrigger: Signal<Void>
    }

    struct Output {
        let emailValidation: Driver<ValidationState>
        let passwordValidation: Driver<ValidationState>
        let areInputsValid: Driver<Bool>
        let loginState: Driver<DiscardableDataState>
    }

    private let loginUserUseCase: LoginUserUseCase
    private let emailValidator: AnyValidator<String>
    private let passwordValidator: AnyValidator<String>

    public init(
        loginUserUseCase: LoginUserUseCase,
        emailValidator: AnyValidator<String>,
        passwordValidator: AnyValidator<String>
    ) {
        self.loginUserUseCase = loginUserUseCase
        self.emailValidator = emailValidator
        self.passwordValidator = passwordValidator
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

        let areInputsValid = Observable
            .combineLatest(
                emailValidation.map { $0 == .valid },
                passwordValidation.map { $0 == .valid }
            )
            .map { $0.0 && $0.1 }

        let loginTrigger = input.loginTrigger
            .asObservable()

        let partialLoginState = loginTrigger
            .withLatestFrom(
                Observable.combineLatest(input.email.asObservable(), input.password.asObservable())
            )
            .flatMap { [unowned self] email, password -> Observable<Event<Void>> in
                let input = LoginUserInput(email: email, password: password)
                return loginUserUseCase.execute(input: input)
                    .andThen(Observable<Void>.just(()))
                    .materialize()
            }
            .compactMap { event -> DiscardableDataState? in
                switch event {
                case .error(let error):
                    return .failed(error.localizedDescription)
                case .next:
                    return .loaded
                case .completed:
                    return nil
                }
            }
            .share()

        let loginState = Observable
            .merge(
                loginTrigger.map { DiscardableDataState.loading },
                partialLoginState
            )
            .startWith(.initial)

        return Output(
            emailValidation: emailValidation.asDriver(onErrorDriveWith: .empty()),
            passwordValidation: passwordValidation.asDriver(onErrorDriveWith: .empty()),
            areInputsValid: areInputsValid.asDriver(onErrorDriveWith: .empty()),
            loginState: loginState.asDriver(onErrorDriveWith: .empty())
        )
    }
}
