//
//  TabsCoordinator.swift
//  GithubApp
//
//  Created by Benjamin Mecanović on 06.08.2022..
//

import UIKit
import RxSwift
import RxCocoa
import Presentation
import Domain

final class TabsCoordinator: Coordinator {

    let tabBarController = UITabBarController()

    private var children: [Coordinator] = []
    private let refreshRelay = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
    private let factory: TabsSceneFactory
    private let logoutRelay: PublishRelay<Void>

    init(
        factory: TabsSceneFactory,
        logoutRelay: PublishRelay<Void>
    ) {
        self.factory = factory
        self.logoutRelay = logoutRelay
    }

    deinit {
        print("Deinited: \(String(describing: self))")
    }

    func start() {
        tabBarController.tabBar.backgroundColor = .systemBackground
        setupSubscriptions()
        showTabsScene()
    }

    private func setupSubscriptions() {}

    private func showTabsScene() {
        let searchRepositoriesCoordinator = factory.makeSearchRepositoriesCoordinator(
            logoutRelay: logoutRelay,
            refreshRelay: refreshRelay
        )

        searchRepositoriesCoordinator.navigationController.tabBarItem = UITabBarItem(
            title: "Search",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )
        children.append(searchRepositoriesCoordinator)
        searchRepositoriesCoordinator.start()

        let favoriteRepositoriesCoordinator = factory.makeFavoriteRepositoriesCoordinator(
            logoutRelay: logoutRelay,
            refreshRelay: refreshRelay
        )

        favoriteRepositoriesCoordinator.navigationController.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(systemName: "heart"),
            selectedImage: UIImage(systemName: "heart")
        )
        children.append(favoriteRepositoriesCoordinator)
        favoriteRepositoriesCoordinator.start()

        tabBarController.setViewControllers(
            [searchRepositoriesCoordinator.navigationController,
             favoriteRepositoriesCoordinator.navigationController
            ],
            animated: true
        )
    }
}
