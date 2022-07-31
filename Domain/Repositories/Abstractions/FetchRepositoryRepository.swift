//
//  FetchRepositoryRepository.swift
//  Domain
//
//  Created by Benjamin Mecanović on 31.07.2022..
//

import Foundation
import RxSwift

public protocol FetchRepositoryRepository {
    func fetch(with input: FetchRepositoryInput) -> Single<Repository>
}
