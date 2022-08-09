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
    private let fetchRepositoryDetailsRepository: FetchRepositoryDetailsRepository

    public init(
        storeFavoriteRepositoryRepository: StoreFavoriteRepositoryRepository,
        removeFavoriteRepositoryRepository: RemoveFavoriteRepositoryRepository,
        fetchUserAccessTokenRepository: FetchUserAccessTokenRepository,
        fetchRepositoryDetailsRepository: FetchRepositoryDetailsRepository
    ) {
        self.storeFavoriteRepositoryRepository = storeFavoriteRepositoryRepository
        self.removeFavoriteRepositoryRepository = removeFavoriteRepositoryRepository
        self.fetchUserAccessTokenRepository = fetchUserAccessTokenRepository
        self.fetchRepositoryDetailsRepository = fetchRepositoryDetailsRepository
    }

    public func execute(input: ToggleFavoriteRepositoryInput) -> Completable {
        fetchUserAccessTokenRepository
            .fetch()
            .flatMapCompletable { [weak self] token in
                guard let self = self else { return .empty() }

                if input.toggle {
                    let removeInput = RemoveFavoriteRepositoryInput(
                        tokenValue: token.value,
                        fetchRepositoryDetailsInput: input.fetchRepositoryDetailsInput
                    )

                    return self.removeFavoriteRepositoryRepository.remove(input: removeInput)
                } else {
                    return self.fetchRepositoryDetailsRepository.fetch(with: input.fetchRepositoryDetailsInput)
                        .flatMapCompletable { repositoryDetails in
                            let storeInput = StoreFavoriteRepositoryInput(
                                tokenValue: token.value,
                                repositoryDetails: repositoryDetails
                            )
                            return self.storeFavoriteRepositoryRepository.store(input: storeInput)
                        }
                }
            }
    }
}
