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
    private let localClient: LocalFetching

    public init(localClient: LocalFetching) {
        self.localClient = localClient
    }

    public func retrieve() -> Single<AccessToken> {
        let response = Single<AccessTokenResponse>.deferred { [weak self] in
            guard let self = self else { return Observable.empty().asSingle() }
            
            return self.localClient
                .fetchInstance(ofType: AccessTokenResponse.self, for: LocalStorageKey.accessToken)
        }

        return response
            .map { AccessToken(value: $0.value) }
    }
}
