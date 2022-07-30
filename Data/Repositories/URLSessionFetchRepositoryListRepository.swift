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

    private let session: URLSession
    private let paginator: Paginator<Repository>
    private let mapper: AnyMapper<RepositoryListResponse, PaginatedResponse<Repository>>
    private let decoder = JSONDecoder()

    public init(session: URLSession,
                paginator: Paginator<Repository>,
                mapper: AnyMapper<RepositoryListResponse, PaginatedResponse<Repository>>) {
        self.session = session
        self.paginator = paginator
        self.mapper = mapper
    }

    public func fetch(with input: FetchRepositoryListInput) -> Single<[Repository]> {
        var urlComponents = URLComponents(string: "https://api.github.com/search/repositories")
        let searchQuery = URLQueryItem(name: "q", value: input.query)
        let perPageQuery = URLQueryItem(name: "per_page", value: paginator.limit.description)
        urlComponents?.queryItems = [searchQuery, perPageQuery]

        guard let url = urlComponents?.url else {
            return .error(URLError(.badURL))
        }

        var request = URLRequest(url: url)
        request.addValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        return fetch(request)
            .map { [weak self] response in
                guard let self = self else { return [] }
                let response = self.mapper.map(input: response)
                return self.paginator.paginate(response)
            }
    }

    private func fetch(_ request: URLRequest) -> Single<RepositoryListResponse> {
        Single.create { [weak self] single in
            guard let self = self else { return Disposables.create() }

            let task = self.session.dataTask(with: request) { [decoder = self.decoder] data, _, error in
                guard let data = data else {
                    return single(.failure(error ?? URLError(.badServerResponse)))
                }

                do {
                    let response = try decoder.decode(RepositoryListResponse.self, from: data)
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
