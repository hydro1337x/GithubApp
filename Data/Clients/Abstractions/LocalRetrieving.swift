//
//  LocalRetrieving.swift
//  Data
//
//  Created by Benjamin Mecanović on 05.08.2022..
//

import Foundation
import RxSwift

public protocol LocalRetrieving {
    func retrieveInstance<T: Decodable>(ofType: T.Type, for key: String) -> Single<T>
}
