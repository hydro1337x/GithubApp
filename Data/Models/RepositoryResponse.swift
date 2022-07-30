//
//  RepositoryResponse.swift
//  Data
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation

struct RepositoryResponse: Decodable {
    let id: String
    let name: String
    let description: String
    let owner: OwnerResponse
    let stargazers_count: Int
    let watchers_count: Int
    let forks_count: Int
    let open_issues_count: Int
}
