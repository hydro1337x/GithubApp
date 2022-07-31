//
//  ConcreteFetchRepositoryListUseCase.swift
//  Domain
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation
import RxSwift

public final class ConcreteFetchRepositoryListUseCase: FetchRepositoryListUseCase {

    private let repository: FetchRepositoryListRepository

    public init(repository: FetchRepositoryListRepository) {
        self.repository = repository
    }

    public func execute(with input: FetchRepositoryListInput) -> Single<[Repository]> {
        input.searchInput.count >= 3 ? repository.fetch(with: input) : .just([])
    }
}
