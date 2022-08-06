//
//  RemoteFetchRepositoryDetailsRepository.swift
//  Data
//
//  Created by Benjamin Mecanović on 04.08.2022..
//

import Foundation
import Domain
import RxSwift

public final class RemoteFetchRepositoryDetailsRepository: FetchRepositoryDetailsRepository {

    private let remoteClient: RemoteSingleFetching
    private let requestMapper: AnyMapper<FetchRepositoryDetailsInput, URLRequest?>
    private let responseMapper: AnyMapper<RepositoryDetailsResponse, RepositoryDetails>
    private let decoder: JSONDecoder

    public init(remoteClient: RemoteSingleFetching,
                requestMapper: AnyMapper<FetchRepositoryDetailsInput, URLRequest?>,
                responseMapper: AnyMapper<RepositoryDetailsResponse, RepositoryDetails>,
                decoder: JSONDecoder
    ) {
        self.remoteClient = remoteClient
        self.requestMapper = requestMapper
        self.responseMapper = responseMapper
        self.decoder = decoder
    }

    public func fetch(with input: FetchRepositoryDetailsInput) -> Single<RepositoryDetails> {
        guard let request = requestMapper.map(input: input) else { return .error(URLError(.badURL)) }

        return remoteClient.fetch(request)
            .compactMap { [weak self] (response: RepositoryDetailsResponse) -> RepositoryDetails? in
                guard let self = self else { return nil }
                
                return self.responseMapper.map(input: response)
            }
            .asObservable()
            .asSingle()
    }
}
