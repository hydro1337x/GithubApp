//
//  RootCoordinator.swift
//  GithubApp
//
//  Created by Benjamin Mecanović on 31.07.2022..
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Presentation
import Domain

final class RootCoordinator: Coordinator {
    let window: UIWindow
    let navigationController = UINavigationController()

    private let selectionRelay = PublishRelay<RepositoryViewModel>()
    private let disposeBag = DisposeBag()
    private let factory: RootSceneFactory

    init(
        window: UIWindow,
        factory: RootSceneFactory
    ) {
        self.window = window
        self.factory = factory
    }

    func start() {
        setupSubscriptions()
        showRootScene()
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
    }

    private func showRootScene() {
        let viewController = factory.makeSearchRepositoresViewController(with: selectionRelay)
        viewController.title = "Search Repositores"
        navigationController.setViewControllers([viewController], animated: false)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    private func showRepositoryDetailsScene(with input: FetchRepositoryDetailsInput) {
        let viewController = factory.makeRepositoryDetailsViewController(with: input)
        navigationController.pushViewController(viewController, animated: true)
    }
}
