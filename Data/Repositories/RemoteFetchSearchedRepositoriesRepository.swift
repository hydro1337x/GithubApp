//
//  RemoteFetchSearchedRepositoriesRepository.swift
//  Data
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation
import Domain
import RxSwift

public final class RemoteFetchSearchedRepositoriesRepository: FetchSearchedRepositoriesRepository {

    let paginator: Paginator<Repository>

    private let remoteClient: RemoteSingleFetching
    private let requestMapper: AnyMapper<FetchRepositoriesRequest, URLRequest?>
    private let responseMapper: AnyMapper<RepositoriesResponse, PaginatedResponse<Repository>>
    private let decoder: JSONDecoder

    public init(remoteClient: RemoteSingleFetching,
                paginator: Paginator<Repository>,
                requestMapper: AnyMapper<FetchRepositoriesRequest, URLRequest?>,
                responseMapper: AnyMapper<RepositoriesResponse, PaginatedResponse<Repository>>,
                decoder: JSONDecoder
    ) {
        self.remoteClient = remoteClient
        self.paginator = paginator
        self.requestMapper = requestMapper
        self.responseMapper = responseMapper
        self.decoder = decoder
    }

    public func fetch(with input: FetchRepositoriesInput) -> Single<[Repository]> {
        if input.isInitialFetch {
            paginator.resetState()
        }

        guard let request = requestMapper.map(
            input: FetchRepositoriesRequest(
                searchInput: input.searchInput,
                currentPage: paginator.currentPage,
                itemsPerPage: paginator.limit
            )
        ) else { return .error(URLError(.badURL)) }

        let response = remoteClient.fetch(request)
            .compactMap { [weak self] (response: RepositoriesResponse) -> PaginatedResponse<Repository>? in
                guard let self = self else { return nil }

                return self.responseMapper.map(input: response)
            }
            .asObservable()
            .asSingle()

        return paginator
            .paginate(response)
            .map { $0.uniqued() }
    }
}
