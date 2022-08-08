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

    public func store(input: UpdateFavoriteRepositoryInput) -> Completable {
        let newRepository = requestMapper.map(input: input.repositoryDetails)
        let key = LocalStorageKey.favoriteRepositories + input.tokenValue

        return localClient.fetchInstance(ofType: [RepositoryDetailsResponse].self, for: key)
            .catch { error in
                if error is NotFoundError {
                    return .just([])
                } else {
                    return .error(error)
                }
            }
            .filter { repositories in repositories.first(where: { $0.id == newRepository.id }) == nil }
            .asObservable()
            .map { repositories -> [RepositoryDetailsResponse] in
                var newRepositories = repositories
                newRepositories.append(newRepository)
                return newRepositories
            }
            .asSingle()
            .flatMapCompletable { [weak self] repositories -> Completable in
                guard let self = self else { return .empty() }
                
                return self.localClient.store(repositories, for: key)
            }
    }
}
