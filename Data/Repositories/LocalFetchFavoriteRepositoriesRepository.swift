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
    private let localClient: LocalFetching
    private let responseMapper: AnyMapper<[RepositoryDetailsResponse], [Repository]>

    public init(
        localClient: LocalFetching,
        responseMapper: AnyMapper<[RepositoryDetailsResponse], [Repository]>
    ) {
        self.localClient = localClient
        self.responseMapper = responseMapper
    }

    public func fetch(input: AccessToken) -> Single<[Repository]> {
        let key = LocalStorageKey.favoriteRepositories + input.value
        return localClient.fetchInstance(ofType: [RepositoryDetailsResponse].self, for: key)
            .map(responseMapper.map(input:))
    }
}
