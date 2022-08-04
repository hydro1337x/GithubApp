//
//  ConcreteFetchRepositoryDetailsUseCase.swift
//  Domain
//
//  Created by Benjamin Mecanović on 31.07.2022..
//

import Foundation
import RxSwift

public final class ConcreteFetchRepositoryDetailsUseCase: FetchRepositoryDetailsUseCase {

    private let repository: FetchRepositoryDetailsRepository

    public init(repository: FetchRepositoryDetailsRepository) {
        self.repository = repository
    }

    public func execute(with input: FetchRepositoryDetailsInput) -> Single<RepositoryDetails> {
        repository.fetch(with: input)
    }
}
