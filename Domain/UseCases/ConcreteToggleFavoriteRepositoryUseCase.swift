//
//  ConcreteToggleFavoriteRepositoryUseCase.swift
//  Domain
//
//  Created by Benjamin Mecanović on 07.08.2022..
//

import Foundation
import RxSwift

public final class ConcreteToggleFavoriteRepositoryUseCase: ToggleFavoriteRepositoryUseCase {

    private let storeFavoriteRepositoryRepository: StoreFavoriteRepositoryRepository
    private let removeFavoriteRepositoryRepository: RemoveFavoriteRepositoryRepository
    private let fetchUserAccessTokenRepository: FetchUserAccessTokenRepository

    public init(
        storeFavoriteRepositoryRepository: StoreFavoriteRepositoryRepository,
        removeFavoriteRepositoryRepository: RemoveFavoriteRepositoryRepository,
        fetchUserAccessTokenRepository: FetchUserAccessTokenRepository
    ) {
        self.storeFavoriteRepositoryRepository = storeFavoriteRepositoryRepository
        self.removeFavoriteRepositoryRepository = removeFavoriteRepositoryRepository
        self.fetchUserAccessTokenRepository = fetchUserAccessTokenRepository
    }

    public func execute(input: ToggleFavoriteRepositoryInput) -> Completable {
        fetchUserAccessTokenRepository
            .fetch()
            .flatMapCompletable { [weak self] token in
                guard let self = self else { return .empty() }

                let repositoryInput = UpdateFavoriteRepositoryInput(
                    tokenValue: token.value,
                    repositoryDetails: input.repositoryDetails
                )

                if input.toggle {
                    return self.removeFavoriteRepositoryRepository.remove(input: repositoryInput)
                } else {
                    return self.storeFavoriteRepositoryRepository.store(input: repositoryInput)
                }
            }
    }
}
