//
//  Owner.swift
//  Domain
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation

public struct Owner {

    public let name: String
    public let avatarURL: String

    public init(name: String, avatarURL: String) {
        self.name = name
        self.avatarURL = avatarURL
    }
}
