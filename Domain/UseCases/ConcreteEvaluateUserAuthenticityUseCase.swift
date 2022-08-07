//
//  ConcreteEvaluateUserAuthenticityUseCase.swift
//  Domain
//
//  Created by Benjamin Mecanović on 05.08.2022..
//

import Foundation
import RxSwift

public final class ConcreteEvaluateUserAuthenticityUseCase: EvaluateUserAuthenticityUseCase {
    private let repository: RetrieveUserAccessTokenRepository
    private let emailValidator: AnyValidator<String>

    public init(
        repository: RetrieveUserAccessTokenRepository,
        emailValidator: AnyValidator<String>
    ) {
        self.repository = repository
        self.emailValidator = emailValidator
    }

    // More complex logic could be applied here, this is a simple check
    // since I am mocking the whole authentication process
    public func execute() -> Completable {
        repository.retrieve()
            .flatMapCompletable { [weak self] token in
                guard let self = self else { return .empty() }

                return self.emailValidator.validate(input: token.value)
            }
    }
}
