//
//  FetchSearchedRepositoriesUseCase.swift
//  Domain
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation
import RxSwift

public protocol FetchSearchedRepositoriesUseCase {
    func execute(with input: FetchRepositoriesInput) -> Single<[Repository]>
}
