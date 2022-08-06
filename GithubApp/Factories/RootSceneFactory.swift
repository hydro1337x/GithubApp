//
//  RootSceneFactory.swift
//  GithubApp
//
//  Created by Benjamin Mecanović on 31.07.2022..
//

import UIKit
import RxSwift
import RxRelay
import Domain
import Data
import Presentation

struct RootSceneFactory {
    typealias Dependencies =
    LoginUserRepositoryInjectable &
    SearchRepositoriesSceneFactory.Dependencies

    let dependencies: Dependencies

    func makeLoginUserViewController(with loginRelay: PublishRelay<Void>) -> UIViewController {
        let emailValidator = BasicEmailValidator().eraseToAnyValidator
        let passwordValidator = BasicPasswordValidator().eraseToAnyValidator
        let loginUserUseCase = ConcreteLoginUserUseCase(repository: dependencies.loginUserRepository)
        let loginUserUseCaseDecorator = LoginUserUseCaseDecorator(
            loginUserUseCase,
            completionRelay: loginRelay
        )
        let viewModel = LoginViewModel(
            loginUserUseCase: loginUserUseCaseDecorator,
            emailValidator: emailValidator,
            passwordValidator: passwordValidator
        )
        let viewController = LoginViewController(viewModel: viewModel)

        return viewController
    }

    func makeSearchRepositoriesCoordinator(with logoutRelay: PublishRelay<Void>) -> SearchRepositoriesCoordinator {
        let factory = SearchRepositoriesSceneFactory(dependencies: dependencies)
        let coordinator = SearchRepositoriesCoordinator(
            factory: factory,
            logoutRelay: logoutRelay
        )

        return coordinator
    }
}
