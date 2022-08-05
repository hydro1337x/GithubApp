//
//  LocalRemoving.swift
//  Data
//
//  Created by Benjamin Mecanović on 05.08.2022..
//

import Foundation
import RxSwift

public protocol LocalRemoving {
    func removeInstance(for key: String) -> Completable
}
