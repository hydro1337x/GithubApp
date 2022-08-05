//
//  NotFoundError.swift
//  Domain
//
//  Created by Benjamin Mecanović on 05.08.2022..
//

import Foundation

public struct NotFoundError: LocalizedError {
    public init() {}
    
    public var errorDescription: String? {
        "Instance not found"
    }
}
