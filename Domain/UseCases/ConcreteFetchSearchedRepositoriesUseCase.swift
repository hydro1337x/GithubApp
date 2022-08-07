//
//  ConcreteFetchSearchedRepositoriesUseCase.swift
//  Domain
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation
import RxSwift

public final class ConcreteFetchSearchedRepositoriesUseCase: FetchSearchedRepositoriesUseCase {

    private let repository: FetchSearchedRepositoriesRepository

    public init(repository: FetchSearchedRepositoriesRepository) {
        self.repository = repository
    }

    public func execute(with input: FetchRepositoriesInput) -> Single<[Repository]> {
        input.searchInput.count >= 3 ? repository.fetch(with: input) : .just([])
    }
}
