//
//  RootCoordinator.swift
//  GithubApp
//
//  Created by Benjamin Mecanović on 31.07.2022..
//

import UIKit
import RxSwift
import RxCocoa
import Presentation
import Domain

final class RootCoordinator: Coordinator {
    let window: UIWindow

    private var children: [Coordinator] = []
    private let loginRelay = PublishRelay<Void>()
    private let logoutRelay = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
    private let factory: RootSceneFactory
    private let logoutUserUseCase: LogoutUserUseCase
    private let evaluateUserAuthenticityUseCase: EvaluateUserAuthenticityUseCase

    init(
        window: UIWindow,
        factory: RootSceneFactory,
        logoutUserUseCase: LogoutUserUseCase,
        evaluateUserAuthenticityUseCase: EvaluateUserAuthenticityUseCase
    ) {
        self.window = window
        self.factory = factory
        self.logoutUserUseCase = logoutUserUseCase
        self.evaluateUserAuthenticityUseCase = evaluateUserAuthenticityUseCase
    }

    func start() {
        setupSubscriptions()
        window.backgroundColor = .systemBackground
        window.makeKeyAndVisible()
    }

    private func setupSubscriptions() {
        loginRelay
            .asSignal()
            .emit(onNext: { [unowned self] in
                showTabsScene()
            })
            .disposed(by: disposeBag)

        logoutRelay
            .flatMap { [unowned self] in
                logoutUserUseCase.execute()
                    .andThen(Observable<Void>.just(()))
                    .catchAndReturn(())
            }
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [unowned self] in
                showLoginScene()
                children.removeAll()
            })
            .disposed(by: disposeBag)

        evaluateUserAuthenticityUseCase
            .execute()
            .observe(on: MainScheduler.instance)
            .subscribe(onCompleted: { [unowned self] in
                showTabsScene()
            }, onError: { [unowned self] error in
                showLoginScene()
            })
            .disposed(by: disposeBag)
    }

    private func showLoginScene() {
        let viewController = factory.makeLoginUserViewController(with: loginRelay)
        let navigationController = UINavigationController(rootViewController: viewController)
        viewController.title = "Login"
        window.rootViewController = navigationController
    }

    private func showTabsScene() {
        let coordinator = factory.makeTabsCoordinator(logoutRelay: logoutRelay)
        children.append(coordinator)
        window.rootViewController = coordinator.tabBarController
        coordinator.start()
    }
}
