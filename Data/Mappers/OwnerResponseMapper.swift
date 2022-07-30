//
//  OwnerResponseMapper.swift
//  Data
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation
import Domain

public final class OwnerResponseMapper: Mapper {

    public init() {}

    public func map(input: OwnerResponse) -> Owner {
        Owner(name: input.login, avatarURL: input.avatar_url)
    }
}
