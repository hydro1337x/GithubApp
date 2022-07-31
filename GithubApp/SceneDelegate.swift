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

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        let scheduler = SerialDispatchQueueScheduler(qos: .userInitiated)
        let session = URLSession(configuration: .default)
        let paginator = Paginator<Repository>(limit: 10, initialPage: 1)
        let repositoryListRequestMapper = FetchRepositoryListRequestMapper().eraseToAnyMapper
        let ownerResponseMapper = OwnerResponseMapper().eraseToAnyMapper
        let repositoryListResponseMapper = RepositoryListResponseMapper(
            ownerResponseMapper: ownerResponseMapper
        ).eraseToAnyMapper
        let fetchRepositoryListRepository = URLSessionFetchRepositoryListRepository(
            session: session,
            paginator: paginator,
            requestMapper: repositoryListRequestMapper,
            responseMapper: repositoryListResponseMapper
        )
        let fetchImageRepository = URLSessionFetchImageRepository(session: session)
        let fetchRepositoryListUseCase = ConcreteFetchRepositoryListUseCase(repository: fetchRepositoryListRepository)
        let fetchImageUseCase = ConcreteFetchImageUseCase(repository: fetchImageRepository)
        let viewModel = SearchRepositoriesViewModel(
            fetchRepositoryListUseCase: fetchRepositoryListUseCase,
            fetchImageUseCase: fetchImageUseCase,
            scheduler: scheduler
        )
        let viewController = SearchRepositoriesViewController(viewModel: viewModel)

        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }
}

