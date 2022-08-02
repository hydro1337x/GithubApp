//
//  URLSessionFetchRepositoryListRepository.swift
//  Data
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation
import Domain
import RxSwift

public final class URLSessionFetchRepositoryListRepository: FetchRepositoryListRepository {

    let paginator: Paginator<Repository>

    private let session: URLSession
    private let requestMapper: AnyMapper<FetchRepositoryListRequest, URLRequest?>
    private let responseMapper: AnyMapper<RepositoryListResponse, PaginatedResponse<Repository>>
    private let decoder = JSONDecoder()

    public init(session: URLSession,
                paginator: Paginator<Repository>,
                requestMapper: AnyMapper<FetchRepositoryListRequest, URLRequest?>,
                responseMapper: AnyMapper<RepositoryListResponse, PaginatedResponse<Repository>>
    ) {
        self.session = session
        self.paginator = paginator
        self.requestMapper = requestMapper
        self.responseMapper = responseMapper
    }

    public func fetch(with input: FetchRepositoryListInput) -> Single<[Repository]> {
        if input.isInitialFetch {
            paginator.resetState()
        }

        guard let request = requestMapper.map(
            input: FetchRepositoryListRequest(
                searchInput: input.searchInput,
                currentPage: paginator.currentPage,
                itemsPerPage: paginator.limit
            )
        ) else { return .error(URLError(.badURL)) }

        let response = fetch(request)
            .compactMap { [weak self] response -> PaginatedResponse<Repository>? in
                guard let self = self else { return nil }

                return self.responseMapper.map(input: response)
            }
            .asObservable()
            .asSingle()

        return paginator
            .paginate(response)
            .map { $0.uniqued() }
    }

    private func fetch(_ request: URLRequest) -> Single<RepositoryListResponse> {
        Single.create { [weak self] single in
            guard let self = self else { return Disposables.create() }

            let task = self.session.dataTask(with: request) { [weak self] data, _, error in
                guard let self = self, let data = data else {
                    return single(.failure(error ?? URLError(.badServerResponse)))
                }

                do {
                    let response = try self.decoder.decode(RepositoryListResponse.self, from: data)
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
