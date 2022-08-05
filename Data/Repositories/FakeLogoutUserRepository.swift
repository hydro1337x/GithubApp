//
//  FakeLogoutUserRepository.swift
//  Data
//
//  Created by Benjamin Mecanović on 05.08.2022..
//

import Foundation
import RxSwift
import Domain

public final class FakeLogoutUserRepository: LogoutUserRepository {

    private let localClient: LocalRemoving

    public init(localClient: LocalRemoving) {
        self.localClient = localClient
    }

    public func logout() -> Completable {
        let deferredTrigger = Single<Void>.deferred { .just(()) }

        return deferredTrigger
            .flatMapCompletable { [weak self] in
                guard let self = self else { return .empty() }

                return self.localClient.removeInstance(for: LoginLocalStorageKey.accessToken)
                    .catch { _ in
                        // Same practice as with login
                        Completable.empty()
                    }
            }
    }
}
