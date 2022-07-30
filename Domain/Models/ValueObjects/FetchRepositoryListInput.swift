//
//  FetchRepositoryListInput.swift
//  Domain
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation

public struct FetchRepositoryListInput {
    public let query: String
    public let isInitialFetch: Bool

    public init(query: String, isInitialFetch: Bool) {
        self.query = query
        self.isInitialFetch = isInitialFetch
    }
}
