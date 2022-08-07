//
//  FetchRepositoriesInput.swift
//  Domain
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation

public struct FetchRepositoriesInput {
    public let searchInput: String
    public let isInitialFetch: Bool

    public init(searchInput: String, isInitialFetch: Bool) {
        self.searchInput = searchInput
        self.isInitialFetch = isInitialFetch
    }
}
