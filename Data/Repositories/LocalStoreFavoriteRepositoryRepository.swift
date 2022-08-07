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
    private let localClient: LocalStoring & LocalFetching
    private let requestMapper: AnyMapper<RepositoryDetails, RepositoryDetailsResponse>

    public init(
        localClient: LocalStoring & LocalFetching,
        requestMapper: AnyMapper<RepositoryDetails, RepositoryDetailsResponse>
    ) {
        self.localClient = localClient
        self.requestMapper = requestMapper
    }

    public func store(input: RepositoryDetails) -> Completable {
        let newRepository = requestMapper.map(input: input)

        return localClient.fetchInstance(ofType: [RepositoryDetailsResponse].self, for: LocalStorageKey.favoriteRepositories)
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
