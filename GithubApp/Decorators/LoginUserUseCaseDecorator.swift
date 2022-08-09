//
//  LoginUserUseCaseDecorator.swift
//  GithubApp
//
//  Created by Benjamin Mecanović on 05.08.2022..
//

import Foundation
import Domain
import RxSwift
import RxRelay

final class LoginUserUseCaseDecorator: LoginUserUseCase {
    private let decoratee: LoginUserUseCase
    private let completionRelay: PublishRelay<Void>

    init(_ decoratee: LoginUserUseCase, completionRelay: PublishRelay<Void>) {
        self.decoratee = decoratee
        self.completionRelay = completionRelay
    }

    func execute(input: LoginUserInput) -> Completable {
        decoratee.execute(input: input)
            .do(onCompleted: { [weak self] in
                guard let self = self else { return }
                self.completionRelay.accept(())
            })
    }
}
