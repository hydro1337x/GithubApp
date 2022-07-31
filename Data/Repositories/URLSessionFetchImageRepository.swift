//
//  URLSessionFetchImageRepository.swift
//  Data
//
//  Created by Benjamin Mecanović on 31.07.2022..
//

import Foundation
import Domain
import RxSwift

public final class URLSessionFetchImageRepository: FetchImageRepository {

    private let session: URLSession

    public init(session: URLSession) {
        self.session = session
    }

    public func fetch(with input: FetchImageInput) -> Single<Data> {
        guard let url = URL(string: input.url) else { return .error(URLError(.badURL)) }

        let request = URLRequest(url: url)

        return fetch(request)
    }

    private func fetch(_ request: URLRequest) -> Single<Data> {
        Single.create { [weak self] single in
            guard let self = self else { return Disposables.create() }

            let task = self.session.dataTask(with: request) { data, _, error in
                guard let data = data else {
                    return single(.failure(error ?? URLError(.badServerResponse)))
                }

                single(.success(data))
            }

            task.resume()

            return Disposables.create {
                task.cancel()
            }
        }
    }
}
