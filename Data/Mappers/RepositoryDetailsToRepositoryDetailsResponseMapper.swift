//
//  RepositoryDetailsToRepositoryDetailsResponseMapper.swift
//  Data
//
//  Created by Benjamin Mecanović on 07.08.2022..
//

import Foundation
import Domain

public final class RepositoryDetailsToRepositoryDetailsResponseMapper: Mapper {
    private let ownerToOwnerResponseMapper: AnyMapper<Owner, OwnerResponse>

    public init(ownerToOwnerResponseMapper: AnyMapper<Owner, OwnerResponse>) {
        self.ownerToOwnerResponseMapper = ownerToOwnerResponseMapper
    }

    public func map(input: RepositoryDetails) -> RepositoryDetailsResponse {
        RepositoryDetailsResponse(
            id: input.id,
            name: input.name,
            description: input.description,
            owner: ownerToOwnerResponseMapper.map(input: input.owner),
            stargazers_count: input.stargazersCount,
            watchers_count: input.watchersCount,
            forks_count: input.forksCount,
            open_issues_count: input.openIssuesCount,
            subscribers_count: input.subscribersCount,
            created_at: input.createdAt,
            updated_at: input.updatedAt
        )
    }
}
