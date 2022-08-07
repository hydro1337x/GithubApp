//
//  ConcreteFetchFavoriteRepositoriesUseCase.swift
//  Domain
//
//  Created by Benjamin Mecanović on 06.08.2022..
//

import Foundation
import RxSwift

public final class ConcreteFetchFavoriteRepositoriesUseCase: FetchFavoriteRepositoriesUseCase {

    private let repository: FetchFavoriteRepositoriesRepository

    public init(repository: FetchFavoriteRepositoriesRepository) {
        self.repository = repository
    }

    public func execute() -> Single<[Repository]> {
        repository.fetch()
    }
}
