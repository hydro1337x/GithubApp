//
//  AnyValidator.swift
//  Domain
//
//  Created by Benjamin Mecanović on 04.08.2022..
//

import Foundation
import RxSwift

public final class AnyValidator<Input>: Validator {
    private let handler: (Input) -> Completable

    public init<Base: Validator>(_ base: Base) where Input == Base.Input {
        self.handler = base.validate
    }

    public func validate(input: Input) -> Completable {
        handler(input)
    }
}
