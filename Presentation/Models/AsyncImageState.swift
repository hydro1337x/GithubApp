//
//  AsyncImageState.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 31.07.2022..
//

import Foundation

enum AsyncImageState {
    case initial
    case loaded(Data)
    case failed
}
