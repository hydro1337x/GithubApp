//
//  MisformattedEmailError.swift
//  Domain
//
//  Created by Benjamin Mecanović on 04.08.2022..
//

import Foundation

public struct MisformattedEmailError: LocalizedError {
    public var errorDescription: String? {
        "Misformatted email"
    }
}
