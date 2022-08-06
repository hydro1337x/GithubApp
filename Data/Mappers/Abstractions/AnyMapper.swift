//
//  AnyMapper.swift
//  Data
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation

public final class AnyMapper<Input, Output>: Mapper {

    private let handler: (Input) -> Output

    public init<Base: Mapper>(_ base: Base) where Base.Input == Input, Base.Output == Output {
        self.handler = base.map(input:)
    }

    public func map(input: Input) -> Output {
        handler(input)
    }
}
