//
//  FetchSearchedRepositoryListRepository.swift
//  Domain
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation
import RxSwift

public protocol FetchSearchedRepositoryListRepository {
    func fetch(with input: FetchRepositoryListInput) -> Single<[Repository]>
}
