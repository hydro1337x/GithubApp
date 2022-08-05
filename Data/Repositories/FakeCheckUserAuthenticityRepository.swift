//
//  FakeRetrieveUserAccessTokenRepository.swift
//  Data
//
//  Created by Benjamin Mecanović on 05.08.2022..
//

import Foundation
import Domain
import RxSwift

public final class FakeRetrieveUserAccessTokenRepository: RetrieveUserAccessTokenRepository {
    private let localClient: LocalRetrieving

    public init(localClient: LocalRetrieving) {
        self.localClient = localClient
    }

    public func retrieve() -> Single<AccessToken> {
        let response = Single<AccessTokenResponse>.deferred { [weak self] in
            guard let self = self else { return Observable.empty().asSingle() }
            
            return self.localClient
                .retrieveInstance(ofType: AccessTokenResponse.self, for: LoginLocalStorageKey.accessToken)
        }

        return response
            .map { AccessToken(value: $0.value) }
    }
}
