//
//  OwnerToOwnerResponseMapper.swift
//  Data
//
//  Created by Benjamin Mecanović on 07.08.2022..
//

import Foundation
import Domain

public final class OwnerToOwnerResponseMapper: Mapper {

    public init() {}

    public func map(input: Owner) -> OwnerResponse {
        OwnerResponse(login: input.name, avatar_url: input.avatarURL)
    }
}
