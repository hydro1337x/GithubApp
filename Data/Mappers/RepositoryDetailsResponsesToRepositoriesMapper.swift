//
//  RepositoryDetailsResponsesToRepositoriesMapper.swift
//  Data
//
//  Created by Benjamin Mecanović on 06.08.2022..
//

import Foundation
import Domain

import Foundation
import Domain

public final class RepositoryDetailsResponsesToRepositoriesMapper: Mapper {
    private let ownerResponseToOwnerMapper: AnyMapper<OwnerResponse, Owner>

    public init(ownerResponseToOwnerMapper: AnyMapper<OwnerResponse, Owner>) {
        self.ownerResponseToOwnerMapper = ownerResponseToOwnerMapper
    }

    public func map(input: [RepositoryDetailsResponse]) -> [Repository] {
        input.map {
            Repository(
                id: $0.id.description,
                name: $0.name,
                owner: ownerResponseToOwnerMapper.map(input: $0.owner),
                stargazersCount: $0.stargazers_count,
                watchersCount: $0.watchers_count,
                forksCount: $0.forks_count,
                openIssuesCount: $0.open_issues_count
            )
        }
    }
}
