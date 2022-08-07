//
//  ToggleFavoriteRepositoryInput.swift
//  Domain
//
//  Created by Benjamin Mecanović on 07.08.2022..
//

import Foundation

public struct ToggleFavoriteRepositoryInput {
    let toggle: Bool
    let repositoryDetails: RepositoryDetails

    public init(toggle: Bool, repositoryDetails: RepositoryDetails) {
        self.toggle = toggle
        self.repositoryDetails = repositoryDetails
    }
}
