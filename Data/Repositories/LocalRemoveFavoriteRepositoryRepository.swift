//
//  LocalRemoveFavoriteRepositoryRepository.swift
//  Data
//
//  Created by Benjamin Mecanović on 07.08.2022..
//

import Foundation
import Domain
import RxSwift

public final class LocalRemoveFavoriteRepositoryRepository: RemoveFavoriteRepositoryRepository {
    private let localClient: LocalStoring & LocalFetching

    public init(localClient: LocalStoring & LocalFetching) {
        self.localClient = localClient
    }

    public func remove(input: RepositoryDetails) -> Completable {
        localClient.fetchInstance(ofType: [RepositoryDetailsResponse].self, for: LocalStorageKey.favoriteRepositories)
            .map { $0.uniqued() }
            .map { repositories -> [RepositoryDetailsResponse] in
                guard let index = repositories.firstIndex(where: { $0.id == input.id }) else { return repositories }

                var repositories = repositories
                repositories.remove(at: index)

                return repositories
            }
            .flatMapCompletable { [weak self] repositories in
                guard let self = self else { return .empty() }

                return self.localClient.store(repositories, for: LocalStorageKey.favoriteRepositories)
            }
    }
}
