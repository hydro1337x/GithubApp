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

    let urlSession = URLSession(configuration: .default)
    let paginator = Paginator<Repository>(limit: 10, initialPage: 1)
    lazy var repositoryListRequestMapper = FetchRepositoryListRequestMapper().eraseToAnyMapper
    lazy var ownerResponseMapper = OwnerResponseMapper().eraseToAnyMapper
    lazy var repositoryListResponseMapper = RepositoryListResponseMapper(
        ownerResponseMapper: ownerResponseMapper
    ).eraseToAnyMapper
    lazy var fetchRepositoryListRepository = URLSessionFetchRepositoryListRepository(
        session: urlSession,
        paginator: paginator,
        requestMapper: repositoryListRequestMapper,
        responseMapper: repositoryListResponseMapper
    )
    lazy var fetchImageRepository = URLSessionFetchImageRepository(session: urlSession)
    lazy var fetchImageUseCase = ConcreteFetchImageUseCase(repository: fetchImageRepository)

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        setupNavigationBarAppearance()

        window = UIWindow(windowScene: windowScene)

        let rootSceneFactory = RootSceneFactory(
            fetchRepositoryListRepository: fetchRepositoryListRepository,
            fetchRepositoryRepository: fetchRepositoryListRepository,
            fetchImageUseCase: fetchImageUseCase
        )
        let coordinator = RootCoordinator(window: window!, factory: rootSceneFactory)
        self.coordinator = coordinator
        coordinator.start()
    }
}

private func setupNavigationBarAppearance() {
    let navBarAppearance = UINavigationBarAppearance()
    navBarAppearance.configureWithOpaqueBackground()
    UINavigationBar.appearance().standardAppearance = navBarAppearance
    UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
}

