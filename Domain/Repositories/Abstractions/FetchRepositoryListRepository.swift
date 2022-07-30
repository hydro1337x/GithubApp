//
//  FetchRepositoryListRepository.swift
//  Domain
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation

import Foundation
import RxSwift

public protocol FetchRepositoryListRepository {
    func fetch(with input: FetchRepositoryListInput) -> Single<[Repository]>
}
