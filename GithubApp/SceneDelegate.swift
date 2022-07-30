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
        
        let session = URLSession(configuration: .default)
        let paginator = Paginator<Repository>(limit: 10)
        let ownerResponseMapper = OwnerResponseMapper().eraseToAnyMapper
        let repositoryListResponseMapper = RepositoryListResponseMapper(
            ownerResponseMapper: ownerResponseMapper
        ).eraseToAnyMapper
        let repository = URLSessionFetchRepositoryListRepository(session: session, paginator: paginator, mapper: repositoryListResponseMapper)
        let useCase = ConcreteFetchRepositoryListUseCase(repository: repository)
        let viewModel = SearchRepositoriesViewModel(fetchRepositoryListUseCase: useCase)
        let viewController = SearchRepositoriesViewController(viewModel: viewModel)

        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }
}

