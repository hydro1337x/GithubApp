//
//  FetchRepositoryDetailsRepositoryDecorator.swift
//  GithubApp
//
//  Created by Benjamin Mecanović on 09.08.2022..
//

import Foundation
import Domain
import RxSwift

final class FetchRepositoryDetailsRepositoryDecorator: FetchRepositoryDetailsRepository {
    private let decoratee: FetchRepositoryDetailsRepository
    private var lastInput: FetchRepositoryDetailsInput?
    private var lastRepositoryDetails: RepositoryDetails?

    init(_ decoratee: FetchRepositoryDetailsRepository) {
        self.decoratee = decoratee
    }

    func fetch(with input: FetchRepositoryDetailsInput) -> Single<RepositoryDetails> {
        if lastInput == input, let lastRepositoryDetails = lastRepositoryDetails {
            return .just(lastRepositoryDetails)
        } else {
            return decoratee.fetch(with: input)
                .do(onSuccess: { [weak self] repositoryDetails in
                    guard let self = self else { return }

                    self.lastInput = input
                    self.lastRepositoryDetails = repositoryDetails
                })
        }
    }
}

extension FetchRepositoryDetailsInput: Equatable {
    public static func == (lhs: FetchRepositoryDetailsInput, rhs: FetchRepositoryDetailsInput) -> Bool {
        lhs.owner == rhs.owner && lhs.name == rhs.name
    }
}
