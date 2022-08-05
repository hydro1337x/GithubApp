//
//  URLSessionLoginUserRepository.swift
//  Data
//
//  Created by Benjamin Mecanović on 05.08.2022..
//

import Foundation
import Domain
import RxSwift

public final class URLSessionLoginUserRepository: LoginUserRepository {
    
    public init() {}

    public func login(input: LoginUserInput) -> Completable {
        return .empty()
    }
}
