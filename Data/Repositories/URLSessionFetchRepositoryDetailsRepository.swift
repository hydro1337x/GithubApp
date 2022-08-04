//
//  URLSessionFetchRepositoryDetailsRepository.swift
//  Data
//
//  Created by Benjamin Mecanović on 04.08.2022..
//

import Foundation
import Domain
import RxSwift

public final class URLSessionFetchRepositoryDetailsRepository: FetchRepositoryDetailsRepository {

    private let session: URLSession
    private let requestMapper: AnyMapper<FetchRepositoryDetailsInput, URLRequest?>
    private let responseMapper: AnyMapper<RepositoryDetailsResponse, RepositoryDetails>
    private let decoder = JSONDecoder()

    public init(session: URLSession,
                requestMapper: AnyMapper<FetchRepositoryDetailsInput, URLRequest?>,
                responseMapper: AnyMapper<RepositoryDetailsResponse, RepositoryDetails>
    ) {
        self.session = session
        self.requestMapper = requestMapper
        self.responseMapper = responseMapper
    }

    public func fetch(with input: FetchRepositoryDetailsInput) -> Single<RepositoryDetails> {
        guard let request = requestMapper.map(input: input) else { return .error(URLError(.badURL)) }

        return fetch(request)
            .compactMap { [weak self] response -> RepositoryDetails? in
                guard let self = self else { return nil }
                return self.responseMapper.map(input: response)
            }
            .asObservable()
            .asSingle()
    }

    private func fetch(_ request: URLRequest) -> Single<RepositoryDetailsResponse> {
        Single.create { [weak self] single in
            guard let self = self else { return Disposables.create() }

            let task = self.session.dataTask(with: request) { [weak self] data, _, error in
                guard let self = self, let data = data else {
                    return single(.failure(error ?? URLError(.badServerResponse)))
                }

                do {
                    let response = try self.decoder.decode(RepositoryDetailsResponse.self, from: data)
                    single(.success(response))
                } catch {
                    single(.failure(error))
                }
            }

            task.resume()

            return Disposables.create {
                task.cancel()
            }
        }
    }
}
