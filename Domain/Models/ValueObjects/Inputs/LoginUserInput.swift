//
//  LoginUserInput.swift
//  Domain
//
//  Created by Benjamin Mecanović on 04.08.2022..
//

import Foundation

public struct LoginUserInput {
    public let email: String
    public let password: String

    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}
