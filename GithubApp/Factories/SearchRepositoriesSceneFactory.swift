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
    typealias Dependencies =
    FetchRepositoryDetailsRepositoryInjectable &
    FetchSearchedRepositoryListRepositoryInjectable &
    RepositoryListMapperInjectable &
    RepositoryDetailsMapperInjectable

    let dependencies: Dependencies

    func makeRepositoryDetailsViewController(with input: FetchRepositoryDetailsInput) -> UIViewController {
        let useCase = ConcreteFetchRepositoryDetailsUseCase(repository: dependencies.fetchRepositoryDetailsRepository)
        let viewModel = RepositoryDetailsViewModel(
            name: input.name,
            owner: input.owner,
            fetchRepositoryDetailsUseCase: useCase,
            repositoryDetailsMapper: dependencies.repositoryDetailsMapper
        )
        let viewController = RepositoryDetailsViewController(viewModel: viewModel)

        return viewController
    }

    func makeSearchRepositoresViewController(
        with selectionRelay: PublishRelay<RepositoryViewModel>
    ) -> UIViewController {
        let scheduler = SerialDispatchQueueScheduler(qos: .userInitiated)
        let fetchSearchedRepositoryListUseCase = ConcreteFetchSearchedRepositoryListUseCase(repository: dependencies.fetchSearchedRepositoryListRepository)
        let viewModel = SearchRepositoriesViewModel(
            fetchSearchedRepositoryListUseCase: fetchSearchedRepositoryListUseCase,
            repositoryListMapper: dependencies.repositoryListMapper,
            scheduler: scheduler
        )
        let viewController = SearchRepositoriesViewController(
            viewModel: viewModel,
            selectionRelay: selectionRelay
        )

        return viewController
    }
}
