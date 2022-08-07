//
//  ConcreteCheckIfRepositoryIsFavoriteUseCase.swift
//  Domain
//
//  Created by Benjamin Mecanović on 07.08.2022..
//

import Foundation
import RxSwift

public final class ConcreteCheckIfRepositoryIsFavoriteUseCase: CheckIfRepositoryIsFavoriteUseCase {
    private let repository: FetchFavoriteRepositoriesRepository

    public init(repository: FetchFavoriteRepositoriesRepository) {
        self.repository = repository
    }

    public func execute(input: FindRepositoryInput) -> Single<Bool> {
        repository.fetch()
            .map { repositories in
                let result = repositories.first(where: {
                    $0.name == input.name && $0.owner.name == input.owner
                })

                return result != nil
            }
    }
}
