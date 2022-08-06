//
//  RemoteSingleFetching.swift
//  Data
//
//  Created by Benjamin Mecanović on 06.08.2022..
//

import Foundation
import RxSwift

public protocol RemoteSingleFetching {
    func fetch<T: Decodable>(_ request: URLRequest) -> Single<T>
}
