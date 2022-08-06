//
//  Mapper.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 06.08.2022..
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
