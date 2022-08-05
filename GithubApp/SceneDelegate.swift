//
//  SceneDelegate.swift
//  GithubApp
//
//  Created by Benjamin Mecanović on 29.07.2022..
//

import UIKit
import Domain
import Data
import Presentation
import RxSwift
import RxCocoa
import RxRelay

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var coordinator: Coordinator?

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let urlSession = URLSession(configuration: .default)
    let paginator = Paginator<Repository>(limit: 10, initialPage: 1)
    let biometricsAuthenticator = BiometricsAuthenticator()
    lazy var localStorageClient = UserDefaultsLocalClient(
        userDefaults: .standard,
        encoder: encoder,
        decoder: decoder
    )
    lazy var repositoryListRequestMapper = FetchRepositoryListRequestMapper().eraseToAnyMapper
    lazy var repositoryDetailsRequestMapper = FetchRepositoryDetailsRequestMapper().eraseToAnyMapper
    lazy var ownerResponseMapper = OwnerResponseMapper().eraseToAnyMapper
    lazy var repositoryListResponseMapper = RepositoryListResponseMapper(
        ownerResponseMapper: ownerResponseMapper
    ).eraseToAnyMapper
    lazy var repositoryDetailsResponseMapper = RepositoryDetailsResponseMapper(
        ownerResponseMapper: ownerResponseMapper
    ).eraseToAnyMapper
    lazy var fetchRepositoryListRepository = URLSessionFetchRepositoryListRepository(
        session: urlSession,
        paginator: paginator,
        requestMapper: repositoryListRequestMapper,
        responseMapper: repositoryListResponseMapper
    )
    lazy var fetchRepositoryDetailsRepository = URLSessionFetchRepositoryDetailsRepository(
        session: urlSession,
        requestMapper: repositoryDetailsRequestMapper,
        responseMapper: repositoryDetailsResponseMapper
    )
    lazy var loginUserRepository = FakeLoginUserRepository(localClient: localStorageClient)
    lazy var logoutUserRepository = FakeLogoutUserRepository(localClient: localStorageClient)
    lazy var retrieveUserAccessTokenRepository = FakeRetrieveUserAccessTokenRepository(localClient: localStorageClient)
    lazy var fetchImageRepository = URLSessionFetchImageRepository(session: urlSession)
    lazy var fetchImageUseCase = ConcreteFetchImageUseCase(repository: fetchImageRepository)
    lazy var logoutUserCase = ConcreteLogoutUserUseCase(repository: logoutUserRepository)
    lazy var evaluateUserAuthenticityUseCase = ConcreteEvaluateUserAuthenticityUseCase(
        repository: retrieveUserAccessTokenRepository,
        emailValidator: BasicEmailValidator().eraseToAnyValidator
    )
    lazy var evaluateUserAuthenticityUseCaseDecorator = EvaluateUserAuthenticityUseCaseDecorator(
        evaluateUserAuthenticityUseCase,
        authenticator: biometricsAuthenticator
    )

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        let rootSceneFactory = RootSceneFactory(
            fetchRepositoryListRepository: fetchRepositoryListRepository,
            fetchImageUseCase: fetchImageUseCase,
            fetchRepositoryDetailsRepository: fetchRepositoryDetailsRepository,
            loginUserRepository: loginUserRepository
        )
        let coordinator = RootCoordinator(
            window: window!,
            factory: rootSceneFactory,
            logoutUserCase: logoutUserCase,
            evaluateUserAuthenticityUseCase: evaluateUserAuthenticityUseCaseDecorator
        )
        self.coordinator = coordinator
        
        coordinator.start()
    }
}

