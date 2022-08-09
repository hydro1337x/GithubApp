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
    ToggleFavoriteRepositoryUseCaseInjectable &
    FetchRepositoryDetailsUseCaseInjectable &
    FetchFavoriteRepositoriesUseCaseInjectable &
    CheckIfRepositoryIsFavoriteUseCaseInjectable

    let dependencies: Dependencies

    func makeRepositoryDetailsViewController(input: FetchRepositoryDetailsInput, refreshRelay: PublishRelay<Void>) -> UIViewController {
        let scheduler = SerialDispatchQueueScheduler(qos: .userInitiated)
        let toggleFavoriteRepositoryUseCaseDecorator = ToggleFavoriteRepositoryUseCaseDecorator(
            dependencies.toggleFavoriteRepositoryUseCase,
            completionRelay: refreshRelay
        )
        let viewModel = RepositoryDetailsViewModel(
            name: input.name,
            owner: input.owner,
            fetchRepositoryDetailsUseCase: dependencies.fetchRepositoryDetailsUseCase,
            toggleFavoriteRepositoryUseCase: toggleFavoriteRepositoryUseCaseDecorator,
            checkIfRepositoryIsFavoriteUseCase: dependencies.checkIfRepositoryIsFavoriteUseCase,
            repositoryDetailsToRepositoryDetailsModelMapper: dependencies.repositoryDetailsToRepositoryDetailsModelMapper,
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
        let viewModel = FavoriteRepositoriesViewModel(
            fetchFavoriteRepositoriesUseCase: dependencies.fetchFavoriteRepositoriesUseCase,
            repositoriesToRepositoryViewModelsMapper: dependencies.repositoriesToRepositoryViewModelsMapper,
            scheduler: scheduler
        )
        let viewController = FavoriteRepositoriesViewController(
            viewModel: viewModel,
            selectionRelay: selectionRelay,
            refreshRelay: refreshRelay
        )

        return viewController
    }
}
