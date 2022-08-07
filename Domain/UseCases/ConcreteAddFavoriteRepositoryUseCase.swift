//
//  ConcreteAddFavoriteRepositoryUseCase.swift
//  Domain
//
//  Created by Benjamin Mecanović on 07.08.2022..
//

import Foundation
import RxSwift

public final class ConcreteAddFavoriteRepositoryUseCase: AddFavoriteRepositoryUseCase {

    private let repository: StoreFavoriteRepositoryRepository

    public init(repository: StoreFavoriteRepositoryRepository) {
        self.repository = repository
    }

    public func execute(input: RepositoryDetails) -> Completable {
        repository.store(input: input)
    }
}
