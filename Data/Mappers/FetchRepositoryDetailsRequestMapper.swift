//
//  FetchRepositoryDetailsRequestMapper.swift
//  Data
//
//  Created by Benjamin Mecanović on 04.08.2022..
//

import Foundation
import Domain

public final class FetchRepositoryDetailsRequestMapper: Mapper {

    public init() {}

    public func map(input: FetchRepositoryDetailsInput) -> URLRequest? {
        guard let url = URL(string: "https://api.github.com/repos/\(input.owner)/\(input.name)") else {
            return nil
        }

        var request = URLRequest(url: url)

        request.addValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        return request
    }
}
