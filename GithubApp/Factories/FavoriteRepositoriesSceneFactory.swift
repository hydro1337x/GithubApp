//
//  FavoriteRepositoriesSceneFactory.swift
//  GithubApp
//
//  Created by Benjamin Mecanović on 06.08.2022..
//

import UIKit
import Presentation
import Data
import Domain
import RxSwift
import RxRelay

struct FavoriteRepositoriesSceneFactory {
    typealias Dependencies =
    FetchFavoriteRepositoryListRepositoryInjectable &
    RepositoryListMapperInjectable &
    FetchRepositoryDetailsRepositoryInjectable &
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

    func makeFavoriteRepositoriesViewController(
        selectionRelay: PublishRelay<RepositoryViewModel>,
        refreshRelay: PublishRelay<Void>
    ) -> UIViewController {
        let scheduler = SerialDispatchQueueScheduler(qos: .userInitiated)
        let fetchFavoriteRepositoryListUseCase = ConcreteFetchFavoriteRepositoryListUseCase(
            repository: dependencies.fetchFavoriteRepositoryListRepository)
        let viewModel = FavoritesViewModel(
            fetchFavoriteRepositoryListUseCase: fetchFavoriteRepositoryListUseCase,
            repositoryListMapper: dependencies.repositoryListMapper,
            scheduler: scheduler
        )
        let viewController = FavoritesViewController(
            viewModel: viewModel,
            selectionRelay: selectionRelay,
            refreshRelay: refreshRelay
        )

        return viewController
    }
}
