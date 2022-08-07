//
//  FetchRepositoriesRequest.swift
//  Data
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation

public struct FetchRepositoriesRequest {
    let searchInput: String
    let currentPage: Int
    let itemsPerPage: Int
}
