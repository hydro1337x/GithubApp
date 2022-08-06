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
    let fetchRepositoryListRepository: FetchRepositoryListRepository
    let fetchRepositoryDetailsRepository: FetchRepositoryDetailsRepository
    let loginUserRepository: LoginUserRepository
    let repositoryListMapper: Presentation.AnyMapper<[Repository], [RepositoryViewModel]>
    let repositoryDetailsMapper: Presentation.AnyMapper<RepositoryDetails, RepositoryDetailsModel>

    func makeLoginUserViewController(with loginRelay: PublishRelay<Void>) -> UIViewController {
        let emailValidator = BasicEmailValidator().eraseToAnyValidator
        let passwordValidator = BasicPasswordValidator().eraseToAnyValidator
        let passwordMismatchValidator = PasswordsMatchingValidator().eraseToAnyValidator
        let loginUserUseCase = ConcreteLoginUserUseCase(repository: loginUserRepository)
        let loginUserUseCaseDecorator = LoginUserUseCaseDecorator(
            loginUserUseCase,
            completionRelay: loginRelay
        )
        let viewModel = LoginViewModel(
            loginUserUseCase: loginUserUseCaseDecorator,
            emailValidator: emailValidator,
            passwordValidator: passwordValidator,
            passwordsMatchingValidator: passwordMismatchValidator
        )
        let viewController = LoginViewController(viewModel: viewModel)

        return viewController
    }

    func makeSearchRepositoriesCoordinator(with logoutRelay: PublishRelay<Void>) -> SearchRepositoriesCoordinator {
        let factory = SearchRepositoriesSceneFactory(
            fetchRepositoryDetailsRepository: fetchRepositoryDetailsRepository,
            fetchRepositoryListRepository: fetchRepositoryListRepository,
            repositoryListMapper: repositoryListMapper,
            repositoryDetailsMapper: repositoryDetailsMapper
        )
        let coordinator = SearchRepositoriesCoordinator(
            factory: factory,
            logoutRelay: logoutRelay
        )

        return coordinator
    }
}
