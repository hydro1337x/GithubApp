//
//  LocalStoring.swift
//  Data
//
//  Created by Benjamin Mecanović on 05.08.2022..
//

import Foundation
import RxSwift

public protocol LocalStoring {
    func store<T: Encodable>(_ instance: T, for key: String) -> Completable
}
