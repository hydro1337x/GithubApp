//
//  FetchFavoriteRepositoriesRepository.swift
//  Domain
//
//  Created by Benjamin Mecanović on 06.08.2022..
//

import Foundation
import RxSwift

public protocol FetchFavoriteRepositoriesRepository {
    func fetch(input: AccessToken) -> Single<[Repository]>
}
