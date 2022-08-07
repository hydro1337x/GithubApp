//
//  TabsSceneFactory.swift
//  GithubApp
//
//  Created by Benjamin Mecanović on 06.08.2022..
//

import Foundation
import RxSwift
import RxRelay

struct TabsSceneFactory {
    typealias Dependencies = SearchRepositoriesSceneFactory.Dependencies & FavoriteRepositoriesSceneFactory.Dependencies

    let dependencies: Dependencies

    func makeSearchRepositoriesCoordinator(logoutRelay: PublishRelay<Void>, refreshRelay: PublishRelay<Void>) -> SearchRepositoriesCoordinator {
        let factory = SearchRepositoriesSceneFactory(dependencies: dependencies)
        let coordinator = SearchRepositoriesCoordinator(
            factory: factory,
            logoutRelay: logoutRelay, refreshRelay: refreshRelay
        )

        return coordinator
    }


    func makeFavoriteRepositoriesCoordinator(logoutRelay: PublishRelay<Void>,
                                             refreshRelay: PublishRelay<Void>) -> FavoriteRepositoriesCoordinator {
        let factory = FavoriteRepositoriesSceneFactory(dependencies: dependencies)
        let coordinator = FavoriteRepositoriesCoordinator(
            factory: factory,
            logoutRelay: logoutRelay,
            refreshRelay: refreshRelay
        )
        
        return coordinator
    }
}
