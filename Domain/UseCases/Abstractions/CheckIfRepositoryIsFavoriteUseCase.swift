//
//  CheckIfRepositoryIsFavoriteUseCase.swift
//  Domain
//
//  Created by Benjamin Mecanović on 07.08.2022..
//

import Foundation
import RxSwift

public protocol CheckIfRepositoryIsFavoriteUseCase {
    func execute(input: FindRepositoryInput) -> Single<Bool>
}
