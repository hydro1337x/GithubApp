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

    private let name: String
    private let owner: String
    private let fetchRepositoryDetailsUseCase: FetchRepositoryDetailsUseCase
    private let fetchImageUseCase: FetchImageUseCase

    public init(
        name: String,
        owner: String,
        fetchRepositoryDetailsUseCase: FetchRepositoryDetailsUseCase,
        fetchImageUseCase: FetchImageUseCase
    ) {
        self.name = name
        self.owner = owner
        self.fetchRepositoryDetailsUseCase = fetchRepositoryDetailsUseCase
        self.fetchImageUseCase = fetchImageUseCase
    }

    func transform(input: Input) -> Output {
        let imageViewModel = input.trigger
            .asObservable()
            .flatMap { [unowned self] in
                fetchRepositoryDetailsUseCase.execute(with: FetchRepositoryDetailsInput(name: name, owner: owner))
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
