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
    typealias Dependencies = LoginUserUseCaseInjectable & TabsSceneFactory.Dependencies

    let dependencies: Dependencies

    func makeLoginUserViewController(with loginRelay: PublishRelay<Void>) -> UIViewController {
        let emailValidator = BasicEmailValidator().eraseToAnyValidator
        let passwordValidator = BasicPasswordValidator().eraseToAnyValidator
        let loginUserUseCaseDecorator = LoginUserUseCaseDecorator(
            dependencies.loginUserUseCase,
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

    func makeTabsCoordinator(logoutRelay: PublishRelay<Void>) -> TabsCoordinator {
        let factory = TabsSceneFactory(dependencies: dependencies)
        let coordinator = TabsCoordinator(factory: factory, logoutRelay: logoutRelay)

        return coordinator
    }
}
