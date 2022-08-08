//
//  ConcreteCheckIfRepositoryIsFavoriteUseCase.swift
//  Domain
//
//  Created by Benjamin Mecanović on 07.08.2022..
//

import Foundation
import RxSwift

public final class ConcreteCheckIfRepositoryIsFavoriteUseCase: CheckIfRepositoryIsFavoriteUseCase {
    private let fetchFavoriteRepositoriesRepository: FetchFavoriteRepositoriesRepository
    private let fetchUserAccessTokenRepository: FetchUserAccessTokenRepository

    public init(
        fetchFavoriteRepositoriesRepository: FetchFavoriteRepositoriesRepository,
        fetchUserAccessTokenRepository: FetchUserAccessTokenRepository
    ) {
        self.fetchFavoriteRepositoriesRepository = fetchFavoriteRepositoriesRepository
        self.fetchUserAccessTokenRepository = fetchUserAccessTokenRepository
    }

    public func execute(input: FindRepositoryInput) -> Single<Bool> {
        fetchUserAccessTokenRepository
            .fetch()
            .flatMap { [weak self] token in
                guard let self = self else { return Observable.empty().asSingle() }

                return self.fetchFavoriteRepositoriesRepository.fetch(input: token)
                    .map { repositories in
                        let result = repositories.first(where: {
                            $0.name == input.name && $0.owner.name == input.owner
                        })

                        return result != nil
                    }
            }

    }
}
