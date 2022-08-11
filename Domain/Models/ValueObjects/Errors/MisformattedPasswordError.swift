//
//  MisformattedPasswordError.swift
//  Domain
//
//  Created by Benjamin Mecanović on 04.08.2022..
//

import Foundation

public struct MisformattedPasswordError: LocalizedError {
    public var errorDescription: String? {
        "Min 6 characters and a special character"
    }

    public init() {}
}
