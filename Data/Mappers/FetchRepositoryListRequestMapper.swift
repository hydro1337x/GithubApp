//
//  FetchRepositoryListRequestMapper.swift
//  Data
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation

public final class FetchRepositoryListRequestMapper: Mapper {

    public init() {}
    
    public func map(input: FetchRepositoryListRequest) -> URLRequest? {
        var urlComponents = URLComponents(string: "https://api.github.com/search/repositories")
        let searchInputQuery = URLQueryItem(name: "q", value: input.searchInput)
        let pageQuery = URLQueryItem(name: "page", value: input.currentPage.description)
        let itemsPerPageQuery = URLQueryItem(name: "per_page", value: input.itemsPerPage.description)

        urlComponents?.queryItems = [searchInputQuery, pageQuery, itemsPerPageQuery]

        guard let url = urlComponents?.url else {
            return nil
        }

        var request = URLRequest(url: url)

        request.addValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        return request
    }
}
