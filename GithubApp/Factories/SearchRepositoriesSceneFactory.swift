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
    RepositoriesToRepositoryViewModelsMapperInjectable &
    RepositoryDetailsToRepositoryDetailsModelMapperInjectable &
    RepositoryDetailsModelToRepositoryDetailsMapperInjectable &
    ToggleFavoriteRepositoryUseCaseInjectable &
    FetchRepositoryDetailsUseCaseInjectable &
    FetchSearchedRepositoriesUseCaseInjectable &
    CheckIfRepositoryIsFavoriteUseCaseInjectable

    let dependencies: Dependencies

    func makeRepositoryDetailsViewController(with input: FetchRepositoryDetailsInput, refreshRelay: PublishRelay<Void>) -> UIViewController {
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
            repositoryDetailsModelToRepositoryDetailsMapper: dependencies.repositoryDetailsModelToRepositoryDetailsMapper,
            scheduler: scheduler
        )
        let viewController = RepositoryDetailsViewController(viewModel: viewModel)

        return viewController
    }

    func makeSearchRepositoresViewController(
        with selectionRelay: PublishRelay<RepositoryViewModel>
    ) -> UIViewController {
        let scheduler = SerialDispatchQueueScheduler(qos: .userInitiated)
        let viewModel = SearchRepositoriesViewModel(
            fetchSearchedRepositoriesUseCase: dependencies.fetchSearchedRepositoriesUseCase,
            repositoriesToRepositoryViewModelsMapper: dependencies.repositoriesToRepositoryViewModelsMapper,
            scheduler: scheduler
        )
        let viewController = SearchRepositoriesViewController(
            viewModel: viewModel,
            selectionRelay: selectionRelay
        )

        return viewController
    }
}
