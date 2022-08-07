//
//  FavoriteRepositoriesCoordinator.swift
//  GithubApp
//
//  Created by Benjamin Mecanović on 07.08.2022..
//

import UIKit
import RxSwift
import RxRelay
import Domain
import Presentation

final class FavoriteRepositoriesCoordinator: Coordinator {

    let navigationController = UINavigationController()
    private let logoutButton = UIBarButtonItem()

    private let selectionRelay = PublishRelay<RepositoryViewModel>()
    private let disposeBag = DisposeBag()
    private let factory: FavoriteRepositoriesSceneFactory
    private let logoutRelay: PublishRelay<Void>
    private let refreshRelay: PublishRelay<Void>

    init(
        factory: FavoriteRepositoriesSceneFactory,
        logoutRelay: PublishRelay<Void>,
        refreshRelay: PublishRelay<Void>
    ) {
        self.factory = factory
        self.logoutRelay = logoutRelay
        self.refreshRelay = refreshRelay
    }

    deinit {
        print("Deinited: \(String(describing: self))")
    }

    func start() {
        setupNavigationItems()
        setupSubscriptions()
        showFavoriteRepositoriesScene()
    }

    private func setupSubscriptions() {
        selectionRelay
            .asSignal()
            .emit(onNext: { [unowned self] input in
                let input = FetchRepositoryDetailsInput(
                    name: input.name,
                    owner: input.ownerName
                )
                showRepositoryDetailsScene(with: input)
            })
            .disposed(by: disposeBag)

        logoutButton.rx
            .tap
            .bind(to: logoutRelay)
            .disposed(by: disposeBag)
    }

    private func showFavoriteRepositoriesScene() {
        let viewController = factory.makeFavoriteRepositoriesViewController(
            selectionRelay: selectionRelay,
            refreshRelay: refreshRelay
        )
        viewController.title = "Favorite Repositories"
        viewController.navigationItem.rightBarButtonItem = logoutButton
        navigationController.setViewControllers([viewController], animated: true)
    }

    private func showRepositoryDetailsScene(with input: FetchRepositoryDetailsInput) {
        let viewController = factory.makeRepositoryDetailsViewController(input: input, refreshRelay: refreshRelay)
        viewController.title = "Repository Details"
        viewController.navigationItem.rightBarButtonItem = logoutButton
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension FavoriteRepositoriesCoordinator {
    private func setupNavigationItems() {
        logoutButton.title = "Logout"
    }
}
