//
//  Mapper.swift
//  Data
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation

public protocol Mapper {
    associatedtype Input
    associatedtype Output

    func map(input: Input) -> Output
}

public extension Mapper {
    var eraseToAnyMapper: AnyMapper<Self.Input, Self.Output> {
        AnyMapper<Self.Input, Self.Output>(self)
    }
}
