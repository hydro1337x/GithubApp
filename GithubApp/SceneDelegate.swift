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
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        return dateFormatter
    }()
    let urlSession = URLSession(configuration: .default)
    lazy var urlSessionWithCache: URLSession = {
        let megabyte = 1024 * 1024
        let memoryCapacity: Int = 50 * megabyte
        let diskCapacity: Int = 200 * megabyte
        let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity)
        let session = URLSession(configuration: .default)
        session.configuration.requestCachePolicy = .reloadRevalidatingCacheData
        session.configuration.urlCache = cache
        return session
    }()
    let paginator = Paginator<Repository>(limit: 10, initialPage: 1)
    let biometricsAuthenticator = BiometricsAuthenticator()
    lazy var localStorageClient = UserDefaultsLocalClient(
        userDefaults: .standard,
        encoder: encoder,
        decoder: decoder
    )
    lazy var remoteClient = URLSessionRemoteClient(session: urlSession, decoder: decoder)
    lazy var repositoryListRequestMapper = FetchRepositoryListRequestMapper().eraseToAnyMapper
    lazy var repositoryDetailsRequestMapper = FetchRepositoryDetailsRequestMapper().eraseToAnyMapper
    lazy var ownerResponseMapper = OwnerResponseMapper().eraseToAnyMapper
    lazy var repositoryListResponseMapper = RepositoryListResponseMapper(
        ownerResponseMapper: ownerResponseMapper
    ).eraseToAnyMapper
    lazy var repositoryDetailsResponseMapper = RepositoryDetailsResponseMapper(
        ownerResponseMapper: ownerResponseMapper
    ).eraseToAnyMapper
    lazy var fetchRepositoryListRepository = RemoteFetchRepositoryListRepository(
        remoteClient: remoteClient,
        paginator: paginator,
        requestMapper: repositoryListRequestMapper,
        responseMapper: repositoryListResponseMapper,
        decoder: decoder
    )
    lazy var fetchRepositoryDetailsRepository = RemoteFetchRepositoryDetailsRepository(
        remoteClient: remoteClient,
        requestMapper: repositoryDetailsRequestMapper,
        responseMapper: repositoryDetailsResponseMapper,
        decoder: decoder
    )
    lazy var loginUserRepository = FakeLoginUserRepository(localClient: localStorageClient)
    lazy var logoutUserRepository = FakeLogoutUserRepository(localClient: localStorageClient)
    lazy var retrieveUserAccessTokenRepository = FakeRetrieveUserAccessTokenRepository(localClient: localStorageClient)
    lazy var fetchImageRepository = RemoteFetchImageRepository(
        remoteClient: URLSessionRemoteClient(
            session: urlSessionWithCache,
            decoder: decoder
        )
    )
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
    lazy var imageURLMapper = ImageURLMapper(fetchImageUseCase: fetchImageUseCase).eraseToAnyMapper
    lazy var dateMapper = DateMapper(
        dateFormatter: dateFormatter,
        inputFormat: "yyyy-MM-dd'T'HH:mm:ssZ",
        outputFormat: "MMM d, yyyy"
    ).eraseToAnyMapper
    lazy var repositoryListMapper = RepositoryListMapper(imageURLMapper: imageURLMapper).eraseToAnyMapper
    lazy var repositoryDetailsMapper = RepositoryDetailsMapper(
        imageURLMapper: imageURLMapper,
        dateMapper: dateMapper
    ).eraseToAnyMapper

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        let rootSceneFactory = RootSceneFactory(
            fetchRepositoryListRepository: fetchRepositoryListRepository,
            fetchRepositoryDetailsRepository: fetchRepositoryDetailsRepository,
            loginUserRepository: loginUserRepository,
            repositoryListMapper: repositoryListMapper,
            repositoryDetailsMapper: repositoryDetailsMapper
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

