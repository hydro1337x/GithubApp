//
//  ValidationState.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 05.08.2022..
//

import Foundation

enum ValidationState: Equatable {
    case empty
    case valid
    case invalid(_ message: String)
}
