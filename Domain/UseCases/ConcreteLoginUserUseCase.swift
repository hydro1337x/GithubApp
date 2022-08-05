//
//  ConcreteLoginUserUseCase.swift
//  Domain
//
//  Created by Benjamin Mecanović on 04.08.2022..
//

import Foundation
import RxSwift

public final class ConcreteLoginUserUseCase: LoginUserUseCase {
    private let repository: LoginUserRepository

    public init(repository: LoginUserRepository) {
        self.repository = repository
    }

    public func execute(input: LoginUserInput) -> Completable {
        repository.login(input: input).delay(.seconds(10), scheduler: SerialDispatchQueueScheduler.init(qos: .userInitiated))
    }
}
