//
//  LocalStoreFavoriteRepositoryRepository.swift
//  Data
//
//  Created by Benjamin Mecanović on 07.08.2022..
//

import Foundation
import Domain
import RxSwift

public final class LocalStoreFavoriteRepositoryRepository: StoreFavoriteRepositoryRepository {
    private let localClient: LocalStoring & LocalRetrieving
    private let requestMapper: AnyMapper<RepositoryDetails, RepositoryDetailsResponse>

    public init(
        localClient: LocalStoring & LocalRetrieving,
        requestMapper: AnyMapper<RepositoryDetails, RepositoryDetailsResponse>
    ) {
        self.localClient = localClient
        self.requestMapper = requestMapper
    }

    public func store(input: RepositoryDetails) -> Completable {
        let newRepository = requestMapper.map(input: input)

        return localClient.retrieveInstance(ofType: [RepositoryDetailsResponse].self, for: LocalStorageKey.favoriteRepositories)
            .catch { error in
                if error is NotFoundError {
                    return .just([])
                } else {
                    return .error(error)
                }
            }
            .map { repositories -> [RepositoryDetailsResponse] in
                var newRepositories = repositories
                newRepositories.append(newRepository)
                return newRepositories
            }
            .flatMapCompletable { [weak self] repositories in
                guard let self = self else { return .empty() }
                return self.localClient.store(repositories, for: LocalStorageKey.favoriteRepositories)
            }
    }
}
