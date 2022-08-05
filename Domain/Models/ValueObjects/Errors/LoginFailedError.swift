//
//  LoginFailedError.swift
//  Domain
//
//  Created by Benjamin Mecanović on 05.08.2022..
//

import Foundation

public struct LoginFailedError: LocalizedError {

    public init() {}
    
    public var errorDescription: String? {
        "Failed to log in"
    }
}
