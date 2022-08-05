//
//  PasswordsMismatchError.swift
//  Domain
//
//  Created by Benjamin Mecanović on 04.08.2022..
//

import Foundation

public struct PasswordsMismatchError: LocalizedError {
    public var errorDescription: String? {
        "Passwords not matching"
    }
}
