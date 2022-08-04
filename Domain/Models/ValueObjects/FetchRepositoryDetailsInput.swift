//
//  FetchRepositoryDetailsInput.swift
//  Domain
//
//  Created by Benjamin Mecanović on 31.07.2022..
//

import Foundation

public struct FetchRepositoryDetailsInput {
    public let name: String
    public let owner: String

    public init(name: String, owner: String) {
        self.name = name
        self.owner = owner
    }
}
