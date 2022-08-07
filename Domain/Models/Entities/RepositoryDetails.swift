//
//  RepositoryDetails.swift
//  Domain
//
//  Created by Benjamin Mecanović on 04.08.2022..
//

import Foundation

public struct RepositoryDetails {
    public let id: Int
    public let name: String
    public let description: String?
    public let owner: Owner
    public let stargazersCount: Int
    public let watchersCount: Int
    public let forksCount: Int
    public let openIssuesCount: Int
    public let subscribersCount: Int
    public let createdAt: String
    public let updatedAt: String

    public init(
        id: Int,
        name: String,
        description: String?,
        owner: Owner,
        stargazersCount: Int,
        watchersCount: Int,
        forksCount: Int,
        openIssuesCount: Int,
        subscribersCount: Int,
        createdAt: String,
        updatedAt: String
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.owner = owner
        self.stargazersCount = stargazersCount
        self.watchersCount = watchersCount
        self.forksCount = forksCount
        self.openIssuesCount = openIssuesCount
        self.subscribersCount = subscribersCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
