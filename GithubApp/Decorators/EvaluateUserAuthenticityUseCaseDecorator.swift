//
//  EvaluateUserAuthenticityUseCaseDecorator.swift
//  GithubApp
//
//  Created by Benjamin Mecanović on 05.08.2022..
//

import Foundation
import Domain
import RxSwift

final class EvaluateUserAuthenticityUseCaseDecorator: EvaluateUserAuthenticityUseCase {
    private let decoratee: EvaluateUserAuthenticityUseCase
    private let authenticator: Authenticator

    init(_ decoratee: EvaluateUserAuthenticityUseCase, authenticator: Authenticator) {
        self.decoratee = decoratee
        self.authenticator = authenticator
    }

    func execute() -> Completable {
        decoratee.execute()
            .andThen(authenticator.evaluate())
    }
}
