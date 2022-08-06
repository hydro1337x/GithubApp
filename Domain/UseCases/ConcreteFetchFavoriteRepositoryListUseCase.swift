//
//  ConcreteFetchFavoriteRepositoryListUseCase.swift
//  Domain
//
//  Created by Benjamin Mecanović on 06.08.2022..
//

import Foundation
import RxSwift

public final class ConcreteFetchFavoriteRepositoryListUseCase: FetchFavoriteRepositoryListUseCase {

    private let repository: FetchFavoriteRepositoryListRepository

    public init(repository: FetchFavoriteRepositoryListRepository) {
        self.repository = repository
    }

    public func execute() -> Single<[Repository]> {
        repository.fetch()
    }
}
