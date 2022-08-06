//
//  URLSessionRemoteClient.swift
//  Data
//
//  Created by Benjamin Mecanović on 06.08.2022..
//

import Foundation
import RxSwift

public final class URLSessionRemoteClient {
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(
        session: URLSession,
        decoder: JSONDecoder
    ) {
        self.session = session
        self.decoder = decoder
    }
}

extension URLSessionRemoteClient: RemoteSingleFetching {
    public func fetch<T: Decodable>(_ request: URLRequest) -> Single<T>  {
        Single.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }

            let task = self.session.dataTask(with: request) { [weak self] data, _, error in
                guard let self = self, let data = data else {
                    return observer(.failure(error ?? URLError(.badServerResponse)))
                }

                // Checks if it is a data request
                if T.self == Data.self, let data = data as? T {
                    observer(.success(data))
                } else {
                    do {
                        let response = try self.decoder.decode(T.self, from: data)
                        observer(.success(response))
                    } catch {
                        observer(.failure(error))
                    }
                }
            }

            task.resume()

            return Disposables.create {
                task.cancel()
            }
        }
    }
}

extension URLSessionRemoteClient: RemoteCompletableFetching {
    public func fetch(_ request: URLRequest) -> Completable {
        Completable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }

            let task = self.session.dataTask(with: request) { _, _, error in
                if let error = error {
                    observer(.error(error))
                } else {
                    observer(.completed)
                }
            }

            task.resume()

            return Disposables.create {
                task.cancel()
            }
        }
    }
}
