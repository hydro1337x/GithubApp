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
        let initialActivity: Driver<Bool>
        let subsequentActivity: Driver<Bool>
        let failureMessage: Signal<String>
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
        let failureTracker = FailureTracker()
        let initialActivityTracker = ActivityTracker()
        let subsequentActivityTracker = ActivityTracker()

        let initialRepositories = input.initialTrigger
            .asObservable()
            .observe(on: scheduler)
            .flatMap { [unowned self] input in
                fetchRepositoryListUseCase.execute(with: FetchRepositoryListInput(query: input, isInitialFetch: true))
                    .trackActivity(initialActivityTracker)
                    .trackFailure(failureTracker)
                    .map { Optional($0) }
                    .catch { _ in
                        Observable<[Repository]?>.just(nil)
                    }
                    .compactMap { $0 }
            }
            .map { [unowned self] repositories in
                map(repositories)
            }

        let subsequentRepositories = input.subsequentTrigger
            .asObservable()
            .filter { $0.currentIndex == ($0.lastIndex ?? 0)  }
            .map(\.text)
            .flatMap { [unowned self] input in
                fetchRepositoryListUseCase.execute(with: FetchRepositoryListInput(query: input, isInitialFetch: false))
                    .trackActivity(subsequentActivityTracker)
                    .trackFailure(failureTracker)
                    .map { Optional($0) }
                    .catch { _ in
                        Observable<[Repository]?>.just(nil)
                    }
                    .compactMap { $0 }
            }
            .map { [unowned self] repositories in
                map(repositories)
            }

        let repositories = Observable.merge(initialRepositories, subsequentRepositories)
            .asDriver(onErrorDriveWith: .empty())

        let initialActivity = initialActivityTracker.asDriver()
        let subsequentActivity = subsequentActivityTracker.asDriver()

        let failureMessage = failureTracker
            .map { $0.localizedDescription }
            .asSignal(onErrorSignalWith: .empty())

        return Output(
            repositories: repositories,
            initialActivity: initialActivity,
            subsequentActivity: subsequentActivity,
            failureMessage: failureMessage
        )
    }

    private func map(_ repositories: [Repository]) -> [RepositoryViewModel] {
        repositories.map {
            RepositoryViewModel(
                id: $0.id,
                ownerName: $0.owner.name,
                ownerAvatarURL: $0.owner.avatarURL,
                name: $0.name
            )
        }
    }
}
