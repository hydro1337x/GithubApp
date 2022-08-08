//
//  RemoveFavoriteRepositoryRepository.swift
//  Domain
//
//  Created by Benjamin Mecanović on 07.08.2022..
//

import Foundation
import RxSwift

public protocol RemoveFavoriteRepositoryRepository {
    func remove(input: UpdateFavoriteRepositoryInput) -> Completable
}
