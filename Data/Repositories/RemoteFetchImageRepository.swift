//
//  RemoteFetchImageRepository.swift
//  Data
//
//  Created by Benjamin Mecanović on 31.07.2022..
//

import Foundation
import Domain
import RxSwift

public final class RemoteFetchImageRepository: FetchImageRepository {

    private let remoteClient: RemoteSingleFetching

    public init(remoteClient: RemoteSingleFetching) {
        self.remoteClient = remoteClient
    }

    public func fetch(with input: FetchImageInput) -> Single<Data> {
        guard let url = URL(string: input.url) else { return .error(URLError(.badURL)) }

        let request = URLRequest(url: url)

        return remoteClient.fetch(request)
    }
}
