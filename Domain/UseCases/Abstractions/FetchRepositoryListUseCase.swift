//
//  FetchRepositoryListUseCase.swift
//  Domain
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation
import RxSwift

public protocol FetchRepositoryListUseCase {
    func execute(with input: FetchRepositoryListInput) -> Single<[Repository]>
}
