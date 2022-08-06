//
//  DiscardableDataState.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 05.08.2022..
//

import Foundation

enum DiscardableDataState: Hashable {
    case initial
    case loading
    case loaded
    case failed(_ message: String)
}
