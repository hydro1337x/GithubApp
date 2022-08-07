//
//  RepositoriesResponseMapper.swift
//  Data
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation
import Domain

public final class RepositoriesResponseMapper: Mapper {
    private let ownerResponseMapper: AnyMapper<OwnerResponse, Owner>

    public init(ownerResponseMapper: AnyMapper<OwnerResponse, Owner>) {
        self.ownerResponseMapper = ownerResponseMapper
    }

    public func map(input: RepositoriesResponse) -> PaginatedResponse<Repository> {
        let pagination = DefaultPagination(total: input.total_count)
        let page = input
            .items
            .map {
                Repository(
                    id: $0.id.description,
                    name: $0.name,
                    owner: ownerResponseMapper.map(input: $0.owner),
                    stargazersCount: $0.stargazers_count,
                    watchersCount: $0.watchers_count,
                    forksCount: $0.forks_count,
                    openIssuesCount: $0.open_issues_count
                )
            }

        return PaginatedResponse(page: page, pagination: pagination)
    }
}
