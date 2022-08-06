//
//  DataState.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 06.08.2022..
//

import Foundation

enum DataState<T: Hashable>: Hashable {
    case initial
    case loading
    case loaded(_ data: T)
    case failed(_ message: String)
}
