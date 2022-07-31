//
//  ConcreteFetchRepositoryUseCase.swift
//  Domain
//
//  Created by Benjamin Mecanović on 31.07.2022..
//

import Foundation
import RxSwift

public final class ConcreteFetchRepositoryUseCase: FetchRepositoryUseCase {

    private let repository: FetchRepositoryRepository

    public init(repository: FetchRepositoryRepository) {
        self.repository = repository
    }

    public func execute(with input: FetchRepositoryInput) -> Single<Repository> {
        repository.fetch(with: input)
    }
}
