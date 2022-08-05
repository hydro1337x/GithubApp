//
//  AuthenticationFailedError.swift
//  Domain
//
//  Created by Benjamin Mecanović on 05.08.2022..
//

import Foundation

public struct AuthenticationFailedError: LocalizedError {

    public init() {}
    
    public var errorDescription: String? {
        "Authentication failed"
    }
}
