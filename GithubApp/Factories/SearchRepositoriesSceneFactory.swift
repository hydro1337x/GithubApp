//
//  SearchRepositoriesSceneFactory.swift
//  GithubApp
//
//  Created by Benjamin Mecanović on 05.08.2022..
//

import UIKit
import Domain
import Data
import Presentation
import RxSwift
import RxRelay

struct SearchRepositoriesSceneFactory {

    let fetchRepositoryDetailsRepository: FetchRepositoryDetailsRepository
    let fetchRepositoryListRepository: FetchRepositoryListRepository
    let repositoryListMapper: Presentation.AnyMapper<[Repository], [RepositoryViewModel]>
    let repositoryDetailsMapper: Presentation.AnyMapper<RepositoryDetails, RepositoryDetailsModel>

    func makeRepositoryDetailsViewController(with input: FetchRepositoryDetailsInput) -> UIViewController {
        let useCase = ConcreteFetchRepositoryDetailsUseCase(repository: fetchRepositoryDetailsRepository)
        let viewModel = RepositoryDetailsViewModel(
            name: input.name,
            owner: input.owner,
            fetchRepositoryDetailsUseCase: useCase,
            repositoryDetailsMapper: repositoryDetailsMapper
        )
        let viewController = RepositoryDetailsViewController(viewModel: viewModel)

        return viewController
    }

    func makeSearchRepositoresViewController(
        with selectionRelay: PublishRelay<RepositoryViewModel>
    ) -> UIViewController {
        let scheduler = SerialDispatchQueueScheduler(qos: .userInitiated)
        let fetchRepositoryListUseCase = ConcreteFetchRepositoryListUseCase(repository: fetchRepositoryListRepository)
        let viewModel = SearchRepositoriesViewModel(
            fetchRepositoryListUseCase: fetchRepositoryListUseCase,
            repositoryListMapper: repositoryListMapper,
            scheduler: scheduler
        )
        let viewController = SearchRepositoriesViewController(
            viewModel: viewModel,
            selectionRelay: selectionRelay
        )

        return viewController
    }
}
