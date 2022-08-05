//
//  FakeLoginUserRepository.swift
//  Data
//
//  Created by Benjamin Mecanović on 05.08.2022..
//

import Foundation
import Domain
import RxSwift

public final class FakeLoginUserRepository: LoginUserRepository {

    private let localClient: LocalStoring
    
    public init(localClient: LocalStoring) {
        self.localClient = localClient
    }

    public func login(input: LoginUserInput) -> Completable {
        let payload = AccessTokenResponse(value: input.email)

        let response = Single<AccessTokenResponse>.deferred {
            Bool.random() ? .just(payload) : .error(AuthenticationFailedError())
        }
        .delay(.seconds(1), scheduler: SerialDispatchQueueScheduler(qos: .userInitiated))
        .flatMapCompletable { [weak self] payload in
            guard let self = self else { return .empty() }

            return self.localClient
                .store(payload, for: LoginLocalStorageKey.accessToken)
                .catch { _ in
                    // We should just log that an error occurred,
                    // since otherwise it would prevent logging in a user if there is
                    // a bug in our local storage implementation which is throwing an error
                    Completable.empty()
                }
        }

        return response
    }
}
