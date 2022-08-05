//
//  PasswordsMatchingValidator.swift
//  Domain
//
//  Created by Benjamin Mecanović on 04.08.2022..
//

import Foundation
import RxSwift

public final class PasswordsMatchingValidator: Validator {
    public init() {}

    public func validate(input: PasswordsInput) -> Completable {
        guard input.password == input.repeatedPassword else { return .error(PasswordsMismatchError()) }

        return .empty()
    }
}
