//
//  RepositoryResponse.swift
//  Data
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation

struct RepositoryResponse: Decodable {
    let id: Int
    let name: String
    let description: String?
    let owner: OwnerResponse
    let stargazers_count: Int
    let watchers_count: Int
    let forks_count: Int
    let open_issues_count: Int
    let url: String
    let created_at: String
    let updated_at: String
}
