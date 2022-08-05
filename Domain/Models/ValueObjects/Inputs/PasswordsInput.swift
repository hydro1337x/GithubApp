//
//  PasswordsInput.swift
//  Domain
//
//  Created by Benjamin Mecanović on 04.08.2022..
//

import Foundation

public struct PasswordsInput {
    let password: String
    let repeatedPassword: String

    public init(password: String, repeatedPassword: String) {
        self.password = password
        self.repeatedPassword = repeatedPassword
    }
}
