//
//  RepositoryDetailsMapper.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 06.08.2022..
//

import Foundation
import Domain

public final class RepositoryDetailsMapper: Mapper {
    private let imageURLMapper: AnyMapper<String, AsyncImageViewModel>
    private let dateMapper: AnyMapper<String, String>

    public init(
        imageURLMapper: AnyMapper<String, AsyncImageViewModel>,
        dateMapper: AnyMapper<String, String>
    ) {
        self.imageURLMapper = imageURLMapper
        self.dateMapper = dateMapper
    }

    public func map(input: RepositoryDetails) -> RepositoryDetailsModel {
        RepositoryDetailsModel(
            id: input.id.description,
            name: input.name,
            description: input.description,
            ownerName: input.owner.name,
            ownerImageViewModel: imageURLMapper.map(input: input.owner.avatarURL),
            stargazersCount: input.stargazersCount.description,
            watchersCount: input.watchersCount.description,
            forksCount: input.forksCount.description,
            openIssuesCount: input.openIssuesCount.description,
            subscribersCount: input.subscribersCount.description,
            createdAt: dateMapper.map(input: input.createdAt),
            updatedAt: dateMapper.map(input: input.updatedAt)
        )
    }
}
