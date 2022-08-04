//
//  RepositoryDetailsResponseMapper.swift
//  Data
//
//  Created by Benjamin Mecanović on 04.08.2022..
//

import Foundation
import Domain

public final class RepositoryDetailsResponseMapper: Mapper {
    private let ownerResponseMapper: AnyMapper<OwnerResponse, Owner>

    public init(ownerResponseMapper: AnyMapper<OwnerResponse, Owner>) {
        self.ownerResponseMapper = ownerResponseMapper
    }

    public func map(input: RepositoryDetailsResponse) -> RepositoryDetails {
        RepositoryDetails(
            id: input.id,
            name: input.name,
            description: input.description,
            owner: ownerResponseMapper.map(input: input.owner),
            stargazersCount: input.stargazers_count,
            watchersCount: input.watchers_count,
            forksCount: input.forks_count,
            openIssuesCount: input.open_issues_count,
            subscribersCount: input.subscribers_count,
            url: input.url,
            createdAt: input.created_at,
            updatedAt: input.updated_at
        )
    }
}
