//
//  SceneDelegate.swift
//  GithubApp
//
//  Created by Benjamin Mecanović on 29.07.2022..
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var coordinator: Coordinator?

    let dependencies = DependencyContainer()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        let rootSceneFactory = RootSceneFactory(dependencies: dependencies)
        let coordinator = RootCoordinator(
            window: window!,
            factory: rootSceneFactory,
            logoutUserUseCase: dependencies.logoutUserUseCase,
            evaluateUserAuthenticityUseCase: dependencies.evaluateUserAuthenticityUseCaseDecorator
        )
        self.coordinator = coordinator
        
        coordinator.start()
    }
}

