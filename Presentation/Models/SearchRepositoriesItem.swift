//
//  SearchRepositoriesItem.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 03.08.2022..
//

import Foundation

public enum SearchRepositoriesItem: Hashable {
    case item(RepositoryViewModel)
    case activity
}
