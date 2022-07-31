//
//  FetchImageRepository.swift
//  Domain
//
//  Created by Benjamin Mecanović on 31.07.2022..
//

import Foundation
import RxSwift

public protocol FetchImageRepository {
    func fetch(with input: FetchImageInput) -> Single<Data>
}
