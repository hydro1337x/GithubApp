//
//  ConcreteFetchImageUseCase.swift
//  Domain
//
//  Created by Benjamin Mecanović on 31.07.2022..
//

import Foundation
import RxSwift

public final class ConcreteFetchImageUseCase: FetchImageUseCase {
    private let repository: FetchImageRepository

    public init(repository: FetchImageRepository) {
        self.repository = repository
    }

    public func execute(with input: FetchImageInput) -> Single<Data> {
        repository.fetch(with: input)
    }
}
