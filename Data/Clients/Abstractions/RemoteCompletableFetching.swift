//
//  RemoteCompletableFetching.swift
//  Data
//
//  Created by Benjamin Mecanović on 06.08.2022..
//

import Foundation
import RxSwift

public protocol RemoteCompletableFetching {
    func fetch(_ request: URLRequest) -> Completable
}
