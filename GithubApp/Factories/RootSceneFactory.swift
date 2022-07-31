//
//  RootSceneFactory.swift
//  GithubApp
//
//  Created by Benjamin Mecanović on 31.07.2022..
//

import Foundation
import UIKit
import RxSwift
import Domain
import Data
import Presentation

struct RootSceneFactory {
    let session: URLSession

    func makeSearchRepositoresViewController() -> UIViewController {
        let scheduler = SerialDispatchQueueScheduler(qos: .userInitiated)
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

        return viewController
    }
}
