//
//  ConcreteLogoutUserUseCase.swift
//  Domain
//
//  Created by Benjamin Mecanović on 05.08.2022..
//

import Foundation
import RxSwift

public final class ConcreteLogoutUserUseCase: LogoutUserUseCase {
    private let repository: LogoutUserRepository

    public init(repository: LogoutUserRepository) {
        self.repository = repository
    }

    public func execute() -> Completable {
        repository.logout()
    }
}
