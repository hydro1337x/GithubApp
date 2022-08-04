//
//  FetchRepositoryDetailsUseCase.swift
//  Domain
//
//  Created by Benjamin Mecanović on 04.08.2022..
//

import Foundation
import RxSwift

public protocol FetchRepositoryDetailsUseCase {
    func execute(with input: FetchRepositoryDetailsInput) -> Single<RepositoryDetails>
}
