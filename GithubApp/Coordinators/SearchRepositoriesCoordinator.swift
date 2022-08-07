//
//  SearchRepositoriesCoordinator.swift
//  GithubApp
//
//  Created by Benjamin Mecanović on 05.08.2022..
//

import UIKit
import RxSwift
import RxRelay
import Domain
import Presentation

final class SearchRepositoriesCoordinator: Coordinator {

    let navigationController = UINavigationController()
    private let logoutButton = UIBarButtonItem()

    private let selectionRelay = PublishRelay<RepositoryViewModel>()
    private let disposeBag = DisposeBag()
    private let factory: SearchRepositoriesSceneFactory
    private let logoutRelay: PublishRelay<Void>
    private let refreshRelay: PublishRelay<Void>

    init(
        factory: SearchRepositoriesSceneFactory,
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
        showSearchRepositoriesScene()
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

    private func showSearchRepositoriesScene() {
        let viewController = factory.makeSearchRepositoresViewController(with: selectionRelay)
        viewController.title = "Search Repositories"
        viewController.navigationItem.rightBarButtonItem = logoutButton
        navigationController.setViewControllers([viewController], animated: true)
    }

    private func showRepositoryDetailsScene(with input: FetchRepositoryDetailsInput) {
        let viewController = factory.makeRepositoryDetailsViewController(with: input, refreshRelay: refreshRelay)
        viewController.title = "Repository Details"
        viewController.navigationItem.rightBarButtonItem = logoutButton
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension SearchRepositoriesCoordinator {
    private func setupNavigationItems() {
        logoutButton.title = "Logout"
    }
}
