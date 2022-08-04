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
    let fetchRepositoryDetailsRepository: FetchRepositoryDetailsRepository

    init(
        fetchRepositoryListRepository: FetchRepositoryListRepository,
        fetchRepositoryDetailsRepository: FetchRepositoryDetailsRepository,
        fetchImageUseCase: FetchImageUseCase
    ) {
        self.fetchRepositoryListRepository = fetchRepositoryListRepository
        self.fetchRepositoryDetailsRepository = fetchRepositoryDetailsRepository
        self.fetchImageUseCase = fetchImageUseCase
    }

    func makeSearchRepositoresViewController(
        with selectionRelay: PublishRelay<RepositoryViewModel>
    ) -> UIViewController {
        let scheduler = SerialDispatchQueueScheduler(qos: .userInitiated)
        let fetchRepositoryListUseCase = ConcreteFetchRepositoryListUseCase(repository: fetchRepositoryListRepository)
        let viewModel = SearchRepositoriesViewModel(
            fetchRepositoryListUseCase: fetchRepositoryListUseCase,
            fetchImageUseCase: fetchImageUseCase,
            scheduler: scheduler
        )
        let viewController = SearchRepositoriesViewController(
            viewModel: viewModel,
            selectionRelay: selectionRelay
        )

        return viewController
    }

    func makeRepositoryDetailsViewController(with input: FetchRepositoryDetailsInput) -> UIViewController {
        let useCase = ConcreteFetchRepositoryDetailsUseCase(repository: fetchRepositoryDetailsRepository)
        let viewModel = RepositoryDetailsViewModel(
            name: input.name,
            owner: input.owner,
            fetchRepositoryDetailsUseCase: useCase,
            fetchImageUseCase: fetchImageUseCase
        )
        let viewController = RepositoryDetailsViewController(viewModel: viewModel)

        return viewController
    }
}
