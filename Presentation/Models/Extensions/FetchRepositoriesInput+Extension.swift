//
//  FetchRepositoriesInput+Extension.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 10.08.2022..
//

import Domain

extension FetchRepositoriesInput: Equatable {
    public static func == (lhs: FetchRepositoriesInput, rhs: FetchRepositoriesInput) -> Bool {
        lhs.isInitialFetch == rhs.isInitialFetch && lhs.searchInput == rhs.searchInput
    }
}
