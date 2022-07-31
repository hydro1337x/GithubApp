//
//  URLSessionFetchRepositoryListRepository+Extension.swift
//  Data
//
//  Created by Benjamin Mecanović on 31.07.2022..
//

import Foundation
import Domain
import RxSwift

extension URLSessionFetchRepositoryListRepository: FetchRepositoryRepository {
    public func fetch(with input: FetchRepositoryInput) -> Single<Repository> {
        guard let repository = paginator.pages.first(where: { $0.id == input.id }) else {
            return .error(URLError(.badServerResponse))
        }

        return .just(repository)
    }
}
