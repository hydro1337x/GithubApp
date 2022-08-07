//
//  RepositoryDetailsResponse.swift
//  Data
//
//  Created by Benjamin Mecanović on 04.08.2022..
//

import Foundation

public struct RepositoryDetailsResponse: Codable, Hashable {
    let id: Int
    let name: String
    let description: String?
    let owner: OwnerResponse
    let stargazers_count: Int
    let watchers_count: Int
    let forks_count: Int
    let open_issues_count: Int
    let subscribers_count: Int
    let created_at: String
    let updated_at: String
}
