//
//  LoginState.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 05.08.2022..
//

import Foundation

enum LoginState: Equatable {
    case initial
    case loading
    case loaded
    case failed(_ message: String)
}
