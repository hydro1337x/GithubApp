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
    public let description: String
    public let owner: Owner
    public let stargazersCount: Int
    public let watchersCount: Int
    public let forksCount: Int
    public let openIssuesCount: Int
}
