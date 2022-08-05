//
//  BasicPasswordValidator.swift
//  Domain
//
//  Created by Benjamin Mecanović on 04.08.2022..
//

import Foundation
import RxSwift

public final class BasicPasswordValidator: Validator {
    private let specialCharacters = #"!#"$%&'()*+,-./:;<=>?@[\]^_`{|}~"#

    public init() {}
    
    public func validate(input: String) -> Completable {
        guard
            input.count > 5,
            !Set(input).isDisjoint(with: specialCharacters)
        else {
            return .error(MisformattedPasswordError())
        }

        return .empty()
    }
}
