//
//  RepositoryDetailsResponseMapper.swift
//  Data
//
//  Created by Benjamin Mecanović on 04.08.2022..
//

import Foundation
import Domain

public final class RepositoryDetailsResponseToRepositoryDetailsMapper: Mapper {
    private let ownerResponseToOwnerMapper: AnyMapper<OwnerResponse, Owner>

    public init(ownerResponseToOwnerMapper: AnyMapper<OwnerResponse, Owner>) {
        self.ownerResponseToOwnerMapper = ownerResponseToOwnerMapper
    }

    public func map(input: RepositoryDetailsResponse) -> RepositoryDetails {
        RepositoryDetails(
            id: input.id,
            name: input.name,
            description: input.description,
            owner: ownerResponseToOwnerMapper.map(input: input.owner),
            stargazersCount: input.stargazers_count,
            watchersCount: input.watchers_count,
            forksCount: input.forks_count,
            openIssuesCount: input.open_issues_count,
            subscribersCount: input.subscribers_count,
            createdAt: input.created_at,
            updatedAt: input.updated_at
        )
    }
}
