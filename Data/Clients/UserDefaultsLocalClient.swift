//
//  UserDefaultsLocalClient.swift
//  Data
//
//  Created by Benjamin Mecanović on 05.08.2022..
//

import Foundation
import RxSwift
import Domain

public final class UserDefaultsLocalClient {
    private let userDefaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(
        userDefaults: UserDefaults,
        encoder: JSONEncoder,
        decoder: JSONDecoder
    ) {
        self.userDefaults = userDefaults
        self.encoder = encoder
        self.decoder = decoder
    }
}

extension UserDefaultsLocalClient: LocalStoring {
    public func store<T: Encodable>(_ instance: T, for key: String) -> Completable {
        let encoded: Data

        do {
            encoded = try encoder.encode(instance)
        } catch {
            return .error(error)
        }

        userDefaults.set(encoded, forKey: key)

        return .empty()
    }
}

extension UserDefaultsLocalClient: LocalFetching {
    public func fetchInstance<T: Decodable>(ofType: T.Type, for key: String) -> Single<T> {
        guard let encoded = userDefaults.object(forKey: key) as? Data else { return .error(NotFoundError()) }

        let decoded: T

        do {
            decoded = try decoder.decode(T.self, from: encoded)
        } catch {
            return .error(error)
        }

        return .just(decoded)
    }
}

extension UserDefaultsLocalClient: LocalRemoving {
    public func removeInstance(for key: String) -> Completable {
        userDefaults.removeObject(forKey: key)

        return .empty()
    }
}
