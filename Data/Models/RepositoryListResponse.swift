//
//  RepositoryListResponse.swift
//  Data
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation

public struct RepositoryListResponse: Decodable {
    let total_count: Int
    let items: [RepositoryResponse]
}
