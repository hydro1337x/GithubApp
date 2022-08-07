//
//  RepositoryDetailsModelToRepositoryDetailsMapper.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 07.08.2022..
//

import Foundation
import Domain

public final class RepositoryDetailsModelToRepositoryDetailsMapper: Mapper {
    private let dateMapper: AnyMapper<String, String>

    public init(dateMapper: AnyMapper<String, String>) {
        self.dateMapper = dateMapper
    }

    public func map(input: RepositoryDetailsModel) -> RepositoryDetails {
        RepositoryDetails(
            id: Int(input.id) ?? 0,
            name: input.name,
            description: input.description,
            owner: Owner(name: input.ownerName, avatarURL: input.ownerImageURL),
            stargazersCount: Int(input.stargazersCount) ?? 0,
            watchersCount: Int(input.watchersCount) ?? 0,
            forksCount: Int(input.forksCount) ?? 0,
            openIssuesCount: Int(input.openIssuesCount) ?? 0,
            subscribersCount: Int(input.subscribersCount) ?? 0,
            createdAt: dateMapper.map(input: input.createdAt),
            updatedAt: dateMapper.map(input: input.updatedAt))
    }
}
