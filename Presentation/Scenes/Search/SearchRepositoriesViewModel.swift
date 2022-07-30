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
        let initialTrigger: Signal<String>
        let subsequentTrigger: Signal<(text: String, currentIndex: Int, lastIndex: Int?)>
    }

    struct Output {
        let repositories: Driver<[RepositoryViewModel]>
    }

    private let fetchRepositoryListUseCase: FetchRepositoryListUseCase
    private let scheduler: SchedulerType

    public init(
        fetchRepositoryListUseCase: FetchRepositoryListUseCase,
        scheduler: SchedulerType
    ) {
        self.fetchRepositoryListUseCase = fetchRepositoryListUseCase
        self.scheduler = scheduler
    }

    func transform(input: Input) -> Output {
        let initialRepositories = Observable
            .merge(input.initialTrigger.asObservable())
            .asObservable()
            .observe(on: scheduler)
            .flatMap { [unowned self] input in
                fetchRepositoryListUseCase.execute(with: FetchRepositoryListInput(query: input, isInitialFetch: true))
            }
            .map { repositories in
                repositories.map {
                    RepositoryViewModel(
                        id: $0.id,
                        ownerName: $0.owner.name,
                        ownerAvatarURL: $0.owner.avatarURL,
                        name: $0.name
                    )
                }
            }

        let subsequentRepositories = input.subsequentTrigger
            .asObservable()
        
            .filter { $0.currentIndex == ($0.lastIndex ?? 0)  }
            .map(\.text)
            .flatMap { [unowned self] input in
                fetchRepositoryListUseCase.execute(with: FetchRepositoryListInput(query: input, isInitialFetch: false))
            }
            .map { repositories in
                repositories.map {
                    RepositoryViewModel(
                        id: $0.id,
                        ownerName: $0.owner.name,
                        ownerAvatarURL: $0.owner.avatarURL,
                        name: $0.name
                    )
                }
            }

        let repositories = Observable.merge(initialRepositories, subsequentRepositories)
            .asDriver(onErrorDriveWith: .empty())

        return Output(repositories: repositories)
    }
}
