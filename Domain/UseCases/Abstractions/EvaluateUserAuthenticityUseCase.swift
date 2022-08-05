//
//  EvaluateUserAuthenticityUseCase.swift
//  Domain
//
//  Created by Benjamin Mecanović on 05.08.2022..
//

import Foundation
import RxSwift

public protocol EvaluateUserAuthenticityUseCase {
    func execute() -> Completable
}
