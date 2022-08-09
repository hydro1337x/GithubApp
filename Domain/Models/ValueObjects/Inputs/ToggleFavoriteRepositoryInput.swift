//
//  ToggleFavoriteRepositoryInput.swift
//  Domain
//
//  Created by Benjamin Mecanović on 07.08.2022..
//

import Foundation

public struct ToggleFavoriteRepositoryInput {
    let toggle: Bool
    let fetchRepositoryDetailsInput: FetchRepositoryDetailsInput

    public init(toggle: Bool, fetchRepositoryDetailsInput: FetchRepositoryDetailsInput) {
        self.toggle = toggle
        self.fetchRepositoryDetailsInput = fetchRepositoryDetailsInput
    }
}
