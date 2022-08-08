//
//  ConcreteFetchFavoriteRepositoriesUseCase.swift
//  Domain
//
//  Created by Benjamin Mecanović on 06.08.2022..
//

import Foundation
import RxSwift

public final class ConcreteFetchFavoriteRepositoriesUseCase: FetchFavoriteRepositoriesUseCase {

    private let fetchFavoriteRepositoriesRepository: FetchFavoriteRepositoriesRepository
    private let fetchUserAccessTokenRepository: FetchUserAccessTokenRepository

    public init(
        fetchFavoriteRepositoriesRepository: FetchFavoriteRepositoriesRepository,
        fetchUserAccessTokenRepository: FetchUserAccessTokenRepository
    ) {
        self.fetchFavoriteRepositoriesRepository = fetchFavoriteRepositoriesRepository
        self.fetchUserAccessTokenRepository = fetchUserAccessTokenRepository
    }

    public func execute() -> Single<[Repository]> {
        fetchUserAccessTokenRepository
            .fetch()
            .flatMap { [weak self] token in
                guard let self = self else { return Observable.empty().asSingle() }

                return self.fetchFavoriteRepositoriesRepository.fetch(input: token)
            }
    }
}
