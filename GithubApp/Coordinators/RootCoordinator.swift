//
//  RootCoordinator.swift
//  GithubApp
//
//  Created by Benjamin Mecanović on 31.07.2022..
//

import Foundation
import UIKit

final class RootCoordinator: Coordinator {
    let window: UIWindow

    private let factory: RootSceneFactory

    init(window: UIWindow,
         factory: RootSceneFactory) {
        self.window = window
        self.factory = factory
    }

    func start() {
        let viewController = factory.makeSearchRepositoresViewController()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
}
