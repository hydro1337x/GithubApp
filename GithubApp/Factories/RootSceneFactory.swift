//
//  RootSceneFactory.swift
//  GithubApp
//
//  Created by Benjamin Mecanović on 31.07.2022..
//

import Foundation
import UIKit
import RxSwift
import RxRelay
import Domain
import Data
import Presentation

struct RootSceneFactory {
    let fetchRepositoryListRepository: FetchRepositoryListRepository
    let fetchImageUseCase: FetchImageUseCase
    let fetchRepositoryRepository: FetchRepositoryRepository

    init(
        fetchRepositoryListRepository: FetchRepositoryListRepository,
        fetchRepositoryRepository: FetchRepositoryRepository,
        fetchImageUseCase: FetchImageUseCase
    ) {
        self.fetchRepositoryListRepository = fetchRepositoryListRepository
        self.fetchRepositoryRepository = fetchRepositoryRepository
        self.fetchImageUseCase = fetchImageUseCase
    }

    func makeSearchRepositoresViewController(
        with selectionRelay: PublishRelay<RepositoryViewModel>
    ) -> UIViewController {
        let fetchTriggerThreshold = 5
        let scheduler = SerialDispatchQueueScheduler(qos: .userInitiated)
        let fetchRepositoryListUseCase = ConcreteFetchRepositoryListUseCase(repository: fetchRepositoryListRepository)
        let viewModel = SearchRepositoriesViewModel(
            fetchRepositoryListUseCase: fetchRepositoryListUseCase,
            fetchImageUseCase: fetchImageUseCase,
            scheduler: scheduler, fetchTriggerThreshold: fetchTriggerThreshold
        )
        let viewController = SearchRepositoriesViewController(
            viewModel: viewModel,
            selectionRelay: selectionRelay
        )

        return viewController
    }

    func makeRepositoryDetailsViewController(with id: String) -> UIViewController {
        let useCase = ConcreteFetchRepositoryUseCase(repository: fetchRepositoryRepository)
        let viewModel = RepositoryDetailsViewModel(
            id: id,
            fetchRepositoryUseCase: useCase,
            fetchImageUseCase: fetchImageUseCase
        )
        let viewController = RepositoryDetailsViewController(viewModel: viewModel)

        return viewController
    }
}
