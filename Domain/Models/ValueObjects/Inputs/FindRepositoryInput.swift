//
//  FindRepositoryInput.swift
//  Domain
//
//  Created by Benjamin Mecanović on 07.08.2022..
//

import Foundation

public struct FindRepositoryInput {
    let name: String
    let owner: String

    public init(name: String, owner: String) {
        self.name = name
        self.owner = owner
    }
}
