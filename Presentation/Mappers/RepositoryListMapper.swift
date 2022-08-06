//
//  RepositoryListMapper.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 06.08.2022..
//

import Foundation
import Domain

public final class RepositoryListMapper: Mapper {
    private let imageURLMapper: AnyMapper<String, AsyncImageViewModel>

    public init(imageURLMapper: AnyMapper<String, AsyncImageViewModel>) {
        self.imageURLMapper = imageURLMapper
    }

    public func map(input: [Repository]) -> [RepositoryViewModel] {
        input.map {
            RepositoryViewModel(
                id: $0.id,
                ownerName: $0.owner.name,
                name: $0.name,
                stargazersCount: $0.stargazersCount.description,
                watchersCount: $0.watchersCount.description,
                forksCount: $0.forksCount.description,
                openIssuesCount: $0.openIssuesCount.description,
                imageViewModel: imageURLMapper.map(input: $0.owner.avatarURL)
            )
        }
    }
}
