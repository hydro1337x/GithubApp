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
    RepositoryListMapperInjectable &
    RepositoryDetailsToRepositoryDetailsModelMapperInjectable &
    RepositoryDetailsModelToRepositoryDetailsMapperInjectable &
    AddFavoriteRepositoryUseCaseInjectable &
    FetchRepositoryDetailsUseCaseInjectable &
    FetchSearchedRepositoriesUseCaseInjectable

    let dependencies: Dependencies

    func makeRepositoryDetailsViewController(with input: FetchRepositoryDetailsInput, refreshRelay: PublishRelay<Void>) -> UIViewController {
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

    func makeSearchRepositoresViewController(
        with selectionRelay: PublishRelay<RepositoryViewModel>
    ) -> UIViewController {
        let scheduler = SerialDispatchQueueScheduler(qos: .userInitiated)
        let viewModel = SearchRepositoriesViewModel(
            fetchSearchedRepositoriesUseCase: dependencies.fetchSearchedRepositoriesUseCase,
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
