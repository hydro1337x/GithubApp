//
//  Repository.swift
//  Domain
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation

public struct Repository {

    public let id: String
    public let name: String
    public let description: String?
    public let owner: Owner
    public let stargazersCount: Int
    public let watchersCount: Int
    public let forksCount: Int
    public let openIssuesCount: Int
    public let url: String
    public let createdAt: String
    public let updatedAt: String

    public init(
        id: String,
        name: String,
        description: String?,
        owner: Owner,
        stargazersCount: Int,
        watchersCount: Int,
        forksCount: Int,
        openIssuesCount: Int,
        url: String,
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
        self.url = url
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
