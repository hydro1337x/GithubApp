//
//  Validator.swift
//  Domain
//
//  Created by Benjamin Mecanović on 04.08.2022..
//

import Foundation
import RxSwift

public protocol Validator {
    associatedtype Input

    func validate(input: Input) -> Completable
}

public extension Validator {
    var eraseToAnyValidator: AnyValidator<Self.Input> {
        AnyValidator<Self.Input>(self)
    }
}
