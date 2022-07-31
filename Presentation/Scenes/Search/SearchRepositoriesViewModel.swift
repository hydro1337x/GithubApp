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
    private let fetchImageUseCase: FetchImageUseCase
    private let scheduler: SchedulerType

    public init(
        fetchRepositoryListUseCase: FetchRepositoryListUseCase,
        fetchImageUseCase: FetchImageUseCase,
        scheduler: SchedulerType
    ) {
        self.fetchRepositoryListUseCase = fetchRepositoryListUseCase
        self.fetchImageUseCase = fetchImageUseCase
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
            .filter { [unowned self] input in
                shouldTriggerSubsequentFetch(for: input.currentIndex, lastIndex: input.lastIndex)
            }
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

    private func shouldTriggerSubsequentFetch(for currentIndex: Int, lastIndex: Int?) -> Bool {
        // Maybe move the parameters to domain and decide there for fetch?
        currentIndex == (lastIndex ?? 0) - 5 // FIX: - might crash if less than 5 repos get fetched
    }

    private func map(_ repositories: [Repository]) -> [RepositoryViewModel] {
        repositories.map {
            RepositoryViewModel(
                id: $0.id,
                ownerName: $0.owner.name,
                name: $0.name,
                stargazersCount: $0.stargazersCount.description,
                watchersCount: $0.watchersCount.description,
                forksCount: $0.forksCount.description,
                openIssuesCount: $0.openIssuesCount.description,
                imageViewModel: map(imageURL: $0.owner.avatarURL)
            )
        }
    }

    private func map(imageURL: String) -> AsyncImageViewModel {
        let input = FetchImageInput(url: imageURL)
        let imageConvertible = fetchImageUseCase
            .execute(with: input)
            .asObservable()
        return AsyncImageViewModel(with: imageConvertible)
    }
}
