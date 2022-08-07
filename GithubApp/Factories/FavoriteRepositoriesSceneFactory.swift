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
    RepositoriesToRepositoryViewModelsMapperInjectable &
    RepositoryDetailsToRepositoryDetailsModelMapperInjectable &
    RepositoryDetailsModelToRepositoryDetailsMapperInjectable &
    AddFavoriteRepositoryUseCaseInjectable &
    FetchRepositoryDetailsUseCaseInjectable &
    FetchFavoriteRepositoriesUseCaseInjectable

    let dependencies: Dependencies

    func makeRepositoryDetailsViewController(input: FetchRepositoryDetailsInput, refreshRelay: PublishRelay<Void>) -> UIViewController {
        let scheduler = SerialDispatchQueueScheduler(qos: .userInitiated)
        let addFavoriteRepositoryUseCaseDecorator = AddFavoriteRepositoryUseCaseDecorator(
            dependencies.addFavoriteRepositoryUseCase,
            completionRelay: refreshRelay
        )
        let viewModel = RepositoryDetailsViewModel(
            name: input.name,
            owner: input.owner,
            fetchRepositoryDetailsUseCase: dependencies.fetchRepositoryDetailsUseCase,
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
        let viewModel = FavoritesViewModel(
            fetchFavoriteRepositoriesUseCase: dependencies.fetchFavoriteRepositoriesUseCase,
            repositoriesToRepositoryViewModelsMapper: dependencies.repositoriesToRepositoryViewModelsMapper,
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
