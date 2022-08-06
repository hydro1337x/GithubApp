//
//  AnyMapper.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 06.08.2022..
//

import Foundation

public final class AnyMapper<Input, Output>: Mapper {

    let handler: (Input) -> Output

    public init<Base: Mapper>(_ base: Base) where Base.Input == Input, Base.Output == Output {
        self.handler = base.map(input:)
    }

    public func map(input: Input) -> Output {
        handler(input)
    }
}
