//
//  LogoutUserRepository.swift
//  Domain
//
//  Created by Benjamin Mecanović on 05.08.2022..
//

import Foundation
import RxSwift

public protocol LogoutUserRepository {
    func logout() -> Completable
}
