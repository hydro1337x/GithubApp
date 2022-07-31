//
//  FetchRepositoryUseCase.swift
//  Domain
//
//  Created by Benjamin Mecanović on 31.07.2022..
//

import Foundation
import RxSwift

public protocol FetchRepositoryUseCase {
    func execute(with input: FetchRepositoryInput) -> Single<Repository>
}
