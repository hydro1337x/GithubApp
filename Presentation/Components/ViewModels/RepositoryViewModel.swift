//
//  RepositoryViewModel.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation

struct RepositoryViewModel: Hashable {
    let id: String
    let ownerName: String
    let ownerAvatarURL: String
    let name: String
    let stargazersCount: String
    let watchersCount: String
    let forksCount: String
    let openIssuesCount: String
}
