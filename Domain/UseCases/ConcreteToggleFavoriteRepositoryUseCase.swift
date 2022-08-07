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

    public init(
        storeFavoriteRepositoryRepository: StoreFavoriteRepositoryRepository,
        removeFavoriteRepositoryRepository: RemoveFavoriteRepositoryRepository
    ) {
        self.storeFavoriteRepositoryRepository = storeFavoriteRepositoryRepository
        self.removeFavoriteRepositoryRepository = removeFavoriteRepositoryRepository
    }

    public func execute(input: ToggleFavoriteRepositoryInput) -> Completable {
        if input.toggle {
            return removeFavoriteRepositoryRepository.remove(input: input.repositoryDetails)
        } else {
            return storeFavoriteRepositoryRepository.store(input: input.repositoryDetails)
        }
    }
}
