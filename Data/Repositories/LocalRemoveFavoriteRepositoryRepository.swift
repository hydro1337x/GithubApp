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

    public func remove(input: RemoveFavoriteRepositoryInput) -> Completable {
        let key = LocalStorageKey.favoriteRepositories + input.tokenValue
        
        return localClient.fetchInstance(ofType: [RepositoryDetailsResponse].self, for: key)
            .map { repositories -> [RepositoryDetailsResponse] in
                guard let index = repositories.firstIndex(where: {
                    $0.owner.login == input.fetchRepositoryDetailsInput.owner &&
                    $0.name == input.fetchRepositoryDetailsInput.name
                }) else {
                    return repositories
                }

                var repositories = repositories
                repositories.remove(at: index)

                return repositories
            }
            .flatMapCompletable { [weak self] repositories in
                guard let self = self else { return .empty() }

                return self.localClient.store(repositories, for: key)
            }
    }
}
