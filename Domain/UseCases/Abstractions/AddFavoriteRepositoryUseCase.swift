//
//  AddFavoriteRepositoryUseCase.swift
//  Domain
//
//  Created by Benjamin Mecanović on 07.08.2022..
//

import Foundation
import RxSwift

public protocol AddFavoriteRepositoryUseCase {
    func execute(input: RepositoryDetails) -> Completable
}
