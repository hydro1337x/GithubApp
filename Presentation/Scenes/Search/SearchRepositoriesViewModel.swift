//
//  SearchRepositoriesViewModel.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation
import RxSwift
import RxCocoa
import Domain

public final class SearchRepositoriesViewModel {
    struct Input {
        let initialTrigger: Signal<Void>
    }

    struct Output {
        let repositories: Driver<[RepositoryViewModel]>
    }

    private let fetchRepositoryListUseCase: FetchRepositoryListUseCase

    public init(fetchRepositoryListUseCase: FetchRepositoryListUseCase) {
        self.fetchRepositoryListUseCase = fetchRepositoryListUseCase
    }

    func transform(input: Input) -> Output {
        let repositories = input.initialTrigger
            .asObservable()
            .flatMap { [unowned self] in
                fetchRepositoryListUseCase.execute(with: FetchRepositoryListInput(query: "aus", isInitialFetch: true))
            }
            .map { repositories in
                repositories.map {
                    RepositoryViewModel(
                        ownerName: $0.owner.name,
                        ownerAvatarURL: $0.owner.avatarURL,
                        name: $0.name
                    )
                }
            }

            return Output(repositories: repositories.asDriver(onErrorDriveWith: .empty()))
    }
}
