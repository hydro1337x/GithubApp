//
//  RepositoryDetailsModel.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 06.08.2022..
//

import Foundation

public struct RepositoryDetailsModel {
    let id: String
    let name: String
    let description: String?
    let ownerName: String
    let ownerImageViewModel: AsyncImageViewModel
    let ownerImageURL: String
    let stargazersCount: String
    let watchersCount: String
    let forksCount: String
    let openIssuesCount: String
    let subscribersCount: String
    let createdAt: String
    let updatedAt: String
}

extension RepositoryDetailsModel: Hashable {
    public static func == (lhs: RepositoryDetailsModel, rhs: RepositoryDetailsModel) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
