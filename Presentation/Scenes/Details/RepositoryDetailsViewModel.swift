//
//  RepositoryDetailsViewModel.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 31.07.2022..
//

import Foundation
import RxSwift
import RxCocoa
import Domain

public final class RepositoryDetailsViewModel {

    struct Input {
        let trigger: Signal<Void>
    }
    struct Output {
        let imageViewModel: Driver<AsyncImageViewModel>
    }

    private let id: String
    private let fetchRepositoryUseCase: FetchRepositoryUseCase
    private let fetchImageUseCase: FetchImageUseCase

    public init(
        id: String,
        fetchRepositoryUseCase: FetchRepositoryUseCase,
        fetchImageUseCase: FetchImageUseCase
    ) {
        self.id = id
        self.fetchRepositoryUseCase = fetchRepositoryUseCase
        self.fetchImageUseCase = fetchImageUseCase
    }

    func transform(input: Input) -> Output {
        let imageViewModel = input.trigger
            .asObservable()
            .flatMap { [unowned self] in
                fetchRepositoryUseCase.execute(with: FetchRepositoryInput(id: id))
            }
            .map { [unowned self] value -> AsyncImageViewModel in
                let imageConvertible = fetchImageUseCase
                    .execute(with: FetchImageInput(url: value.owner.avatarURL))
                    .asObservable()
                return AsyncImageViewModel(with: imageConvertible)
            }
            .asDriver(onErrorDriveWith: .empty())

        return Output(imageViewModel: imageViewModel)
    }
}
