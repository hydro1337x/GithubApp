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

final class RootCoordinator: Coordinator {
    let window: UIWindow

    private let factory: RootSceneFactory

    init(window: UIWindow,
         factory: RootSceneFactory) {
        self.window = window
        self.factory = factory
    }

    func start() {
        showRootScene()
    }

    private func showRootScene() {
        let viewController = factory.makeSearchRepositoresViewController()
        viewController.title = "Search Repositores"
        let navigationController = UINavigationController(rootViewController: viewController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
