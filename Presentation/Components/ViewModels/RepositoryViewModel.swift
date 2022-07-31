//
//  RepositoryViewModel.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation

struct RepositoryViewModel {
    let id: String
    let ownerName: String
    let name: String
    let stargazersCount: String
    let watchersCount: String
    let forksCount: String
    let openIssuesCount: String
    let imageViewModel: AsyncImageViewModel
}

extension RepositoryViewModel: Hashable {
    static func == (lhs: RepositoryViewModel, rhs: RepositoryViewModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
