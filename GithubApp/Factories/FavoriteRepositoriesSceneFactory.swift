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
    FetchFavoriteRepositoriesRepositoryInjectable &
    RepositoryListMapperInjectable &
    FetchRepositoryDetailsRepositoryInjectable &
    RepositoryDetailsToRepositoryDetailsModelMapperInjectable &
    RepositoryDetailsModelToRepositoryDetailsMapperInjectable &
    StoreFavoriteRepositoryRepositoryInjectable

    let dependencies: Dependencies

    func makeRepositoryDetailsViewController(input: FetchRepositoryDetailsInput, refreshRelay: PublishRelay<Void>) -> UIViewController {
        let scheduler = SerialDispatchQueueScheduler(qos: .userInitiated)
        let fetchRepositoryDetailsUseCase = ConcreteFetchRepositoryDetailsUseCase(
            repository: dependencies.fetchRepositoryDetailsRepository
        )
        let addFavoriteRepositoryUseCase = ConcreteAddFavoriteRepositoryUseCase(
            repository: dependencies.storeFavoriteRepositoryRepository
        )
        let addFavoriteRepositoryUseCaseDecorator = AddFavoriteRepositoryUseCaseDecorator(addFavoriteRepositoryUseCase, completionRelay: refreshRelay)
        let viewModel = RepositoryDetailsViewModel(
            name: input.name,
            owner: input.owner,
            fetchRepositoryDetailsUseCase: fetchRepositoryDetailsUseCase,
            addFavoriteRepositoryUseCase: addFavoriteRepositoryUseCaseDecorator,
            repositoryDetailsToRepositoryDetailsModelMapper: dependencies.repositoryDetailsToRepositoryDetailsModelMapper,
            repositoryDetailsModelToRepositoryDetailsMapper: dependencies.repositoryDetailsModelToRepositoryDetailsMapper,
            scheduler: scheduler
        )
        let viewController = RepositoryDetailsViewController(viewModel: viewModel)

        return viewController
    }

    func makeFavoriteRepositoriesViewController(
        selectionRelay: PublishRelay<RepositoryViewModel>,
        refreshRelay: PublishRelay<Void>
    ) -> UIViewController {
        let scheduler = SerialDispatchQueueScheduler(qos: .userInitiated)
        let fetchFavoriteRepositoriesUseCase = ConcreteFetchFavoriteRepositoriesUseCase(
            repository: dependencies.fetchFavoriteRepositoriesRepository)
        let viewModel = FavoritesViewModel(
            fetchFavoriteRepositoriesUseCase: fetchFavoriteRepositoriesUseCase,
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
