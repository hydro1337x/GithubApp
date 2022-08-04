//
//  RepositoryViewModel.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation

public struct RepositoryViewModel {
    let id: String
    public let ownerName: String
    public let name: String
    let stargazersCount: String
    let watchersCount: String
    let forksCount: String
    let openIssuesCount: String
    let imageViewModel: AsyncImageViewModel
}

extension RepositoryViewModel: Hashable {
    public static func == (lhs: RepositoryViewModel, rhs: RepositoryViewModel) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
