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
        let searchTrigger: Signal<String?>
        let refreshTrigger: Signal<String?>
        let subsequentTrigger: Signal<(text: String?, currentIndex: Int, lastIndex: Int?)>
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
    private let fetchTriggerThreshold: Int

    public init(
        fetchRepositoryListUseCase: FetchRepositoryListUseCase,
        fetchImageUseCase: FetchImageUseCase,
        scheduler: SchedulerType,
        fetchTriggerThreshold: Int
    ) {
        self.fetchRepositoryListUseCase = fetchRepositoryListUseCase
        self.fetchImageUseCase = fetchImageUseCase
        self.scheduler = scheduler
        self.fetchTriggerThreshold = fetchTriggerThreshold
    }

    func transform(input: Input) -> Output {
        let failureTracker = FailureTracker()
        let initialActivityTracker = ActivityTracker()
        let subsequentActivityTracker = ActivityTracker()

        let refreshTrigger = input.refreshTrigger.asObservable()
        let searchTrigger = input.searchTrigger
            .asObservable()
            .debounce(.milliseconds(500), scheduler: scheduler)

        let initialRepositories = Observable
            .merge(
                refreshTrigger,
                searchTrigger
            )
            .asObservable()
            .observe(on: scheduler)
            .compactMap { $0 }
            .flatMap { [unowned self] input in
                fetchRepositoryListUseCase.execute(with: FetchRepositoryListInput(searchInput: input,
                                                                                  isInitialFetch: true))
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
                shouldTriggerFetch(for: input.currentIndex, lastIndex: input.lastIndex)
            }
            .compactMap(\.text)
            .flatMap { [unowned self] input in
                fetchRepositoryListUseCase.execute(with: FetchRepositoryListInput(searchInput: input,
                                                                                  isInitialFetch: false))
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

    private func shouldTriggerFetch(for currentIndex: Int, lastIndex: Int?) -> Bool {
        guard let lastIndex = lastIndex else { return false }

        return currentIndex == lastIndex - fetchTriggerThreshold
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
