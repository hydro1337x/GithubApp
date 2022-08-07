//
//  LocalFetchFavoriteRepositoriesRepository.swift
//  Data
//
//  Created by Benjamin Mecanović on 06.08.2022..
//

import Foundation
import Domain
import RxSwift

public final class LocalFetchFavoriteRepositoriesRepository: FetchFavoriteRepositoriesRepository {
    private let localClient: LocalRetrieving
    private let responseMapper: AnyMapper<[RepositoryDetailsResponse], [Repository]>

    public init(
        localClient: LocalRetrieving,
        responseMapper: AnyMapper<[RepositoryDetailsResponse], [Repository]>
    ) {
        self.localClient = localClient
        self.responseMapper = responseMapper
    }

    public func fetch() -> Single<[Repository]> {
        localClient.retrieveInstance(ofType: [RepositoryDetailsResponse].self, for: LocalStorageKey.favoriteRepositories)
            .map(responseMapper.map(input:))
            .map { $0.uniqued() }
    }
}
