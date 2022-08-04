//
//  FetchRepositoryDetailsRepository.swift
//  Domain
//
//  Created by Benjamin Mecanović on 31.07.2022..
//

import Foundation
import RxSwift

public protocol FetchRepositoryDetailsRepository {
    func fetch(with input: FetchRepositoryDetailsInput) -> Single<RepositoryDetails>
}
