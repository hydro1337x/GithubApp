//
//  FetchImageUseCase.swift
//  Domain
//
//  Created by Benjamin Mecanović on 31.07.2022..
//

import Foundation
import RxSwift

public protocol FetchImageUseCase {
    func execute(with input: FetchImageInput) -> Single<Data>
}
