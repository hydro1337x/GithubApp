//
//  URLToAsyncImageViewModelMapper.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 06.08.2022..
//

import Foundation
import Domain

public final class URLToAsyncImageViewModelMapper: Mapper {
    private let fetchImageUseCase: FetchImageUseCase

    public init(fetchImageUseCase: FetchImageUseCase) {
        self.fetchImageUseCase = fetchImageUseCase
    }
    
    public func map(input: String) -> AsyncImageViewModel {
        let input = FetchImageInput(url: input)
        let imageConvertible = fetchImageUseCase
            .execute(with: input)
            .asObservable()
        return AsyncImageViewModel(with: imageConvertible)
    }
}
