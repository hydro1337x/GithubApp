//
//  BasicEmailValidator.swift
//  Domain
//
//  Created by Benjamin Mecanović on 04.08.2022..
//

import Foundation
import RxSwift

public final class BasicEmailValidator: Validator {
    private let emailRegex = #"^\S+@\S+\.\S+$"#
    
    public init() {}

    public func validate(input: String) -> Completable {
        let result = input.range(
            of: emailRegex,
            options: .regularExpression
        )

        guard result != nil else { return .error(MisformattedEmailError()) }

        return .empty()
    }
}
