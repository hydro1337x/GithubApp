//
//  RepositoryListResponseMapper.swift
//  Data
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation
import Domain

public final class RepositoryListResponseMapper: Mapper {
    private let ownerMapper: AnyMapper<OwnerResponse, Owner>

    public init(ownerMapper: AnyMapper<OwnerResponse, Owner>) {
        self.ownerMapper = ownerMapper
    }

    public func map(input: RepositoryListResponse) -> PaginatedResponse<Repository> {
        let pagination = DefaultPagination(total: input.total_count)
        let page = input
            .items
            .map {
                Repository(
                    id: $0.id,
                    name: $0.name,
                    description: $0.description,
                    owner: ownerMapper.map(input: $0.owner),
                    stargazersCount: $0.stargazers_count,
                    watchersCount: $0.watchers_count,
                    forksCount: $0.forks_count,
                    openIssuesCount: $0.open_issues_count)
            }

        return PaginatedResponse(page: page, pagination: pagination)
    }
}
