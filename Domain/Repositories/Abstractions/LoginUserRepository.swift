//
//  LoginUserRepository.swift
//  Domain
//
//  Created by Benjamin Mecanović on 04.08.2022..
//

import Foundation
import RxSwift

public protocol LoginUserRepository {
    func login(input: LoginUserInput) -> Completable
}
