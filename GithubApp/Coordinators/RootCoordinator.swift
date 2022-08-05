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
    private let logoutUserCase: LogoutUserUseCase
    private let evaluateUserAuthenticityUseCase: EvaluateUserAuthenticityUseCase

    init(
        window: UIWindow,
        factory: RootSceneFactory,
        logoutUserCase: LogoutUserUseCase,
        evaluateUserAuthenticityUseCase: EvaluateUserAuthenticityUseCase
    ) {
        self.window = window
        self.factory = factory
        self.logoutUserCase = logoutUserCase
        self.evaluateUserAuthenticityUseCase = evaluateUserAuthenticityUseCase
    }

    deinit {
        print("Deinited: \(String(describing: self))")
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
                showSearchRepositoriesScene()
            })
            .disposed(by: disposeBag)

        logoutRelay
            .flatMap { [unowned self] in
                logoutUserCase.execute()
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
                showSearchRepositoriesScene()
            }, onError: { [unowned self] _ in
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

    private func showSearchRepositoriesScene() {
        let coordinator = factory.makeSearchRepositoriesCoordinator(with: logoutRelay)
        children.append(coordinator)
        window.rootViewController = coordinator.navigationController
        coordinator.start()
    }
}
