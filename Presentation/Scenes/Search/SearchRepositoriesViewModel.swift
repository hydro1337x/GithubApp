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
        let searchTrigger: Signal<String>
        let refreshTrigger: Signal<String>
        let subsequentTrigger: Signal<String>
    }

    struct Output {
        let items: Driver<[SearchRepositoriesItem]>
        let refreshActivity: Driver<Bool>
        let searchActivity: Driver<Bool>
        let failureMessage: Signal<String>
    }

    private let fetchSearchedRepositoryListUseCase: FetchSearchedRepositoryListUseCase
    private let repositoryListMapper: AnyMapper<[Repository], [RepositoryViewModel]>
    private let scheduler: SchedulerType

    public init(
        fetchSearchedRepositoryListUseCase: FetchSearchedRepositoryListUseCase,
        repositoryListMapper: AnyMapper<[Repository], [RepositoryViewModel]>,
        scheduler: SchedulerType
    ) {
        self.fetchSearchedRepositoryListUseCase = fetchSearchedRepositoryListUseCase
        self.repositoryListMapper = repositoryListMapper
        self.scheduler = scheduler
    }

    func transform(input: Input) -> Output {
        let failureTracker = FailureTracker()
        let refreshActivityTracker = ActivityTracker()
        let searchActivityTracker = ActivityTracker()
        let subsequentActivityTracker = ActivityTracker()
        var isSubsequentFetchInProgress = false

        let refreshedRepositories = input.refreshTrigger
            .asObservable()
            .observe(on: scheduler)
            .flatMap { [unowned self] input -> Observable<[Repository]> in
                let input = FetchRepositoryListInput(searchInput: input, isInitialFetch: true)
                return fetch(with: input, using: refreshActivityTracker, and: failureTracker)
            }
            .share()

        let searchedRepositories = input.searchTrigger
            .asObservable()
            .debounce(.milliseconds(500), scheduler: scheduler)
            .observe(on: scheduler)
            .flatMap { [unowned self] input -> Observable<[Repository]> in
                let input = FetchRepositoryListInput(searchInput: input, isInitialFetch: true)
                return fetch(with: input, using: searchActivityTracker, and: failureTracker)
            }
            .share()

        let subsequentRepositories = input.subsequentTrigger
            .asObservable()
            .observe(on: scheduler)
            .filter { _ in !isSubsequentFetchInProgress }
            .do(onNext: { _ in
                isSubsequentFetchInProgress = true
            })
            .flatMap { [unowned self] input -> Observable<[Repository]> in
                let input = FetchRepositoryListInput(searchInput: input, isInitialFetch: false)
                return fetch(with: input, using: subsequentActivityTracker, and: failureTracker)
            }
            .share()
            .do(onNext: { _ in
                isSubsequentFetchInProgress = false
            })


        let repositories = Observable.merge(refreshedRepositories, searchedRepositories, subsequentRepositories)
            .map { [unowned self] repositories in
                repositoryListMapper.map(input: repositories)
            }

        let items = Observable.combineLatest(repositories, subsequentActivityTracker.asObservable())
            .map { repositories, isLoading -> [SearchRepositoriesItem] in
                var items = repositories.map { SearchRepositoriesItem.item($0) }
                if isLoading {
                    items.append(SearchRepositoriesItem.activity)
                }
                return items
            }

        let failureMessage = failureTracker
            .map { $0.localizedDescription }


        return Output(
            items: items.asDriver(onErrorDriveWith: .empty()),
            refreshActivity: refreshActivityTracker.asDriver(),
            searchActivity: searchActivityTracker.asDriver(),
            failureMessage: failureMessage.asSignal(onErrorSignalWith: .empty())
        )
    }

    private func fetch(with input: FetchRepositoryListInput, using activityTracker: ActivityTracker, and failureTracker: FailureTracker) -> Observable<[Repository]> {
        fetchSearchedRepositoryListUseCase.execute(with: input)
            .trackActivity(activityTracker)
            .trackFailure(failureTracker)
            .map { Optional($0) }
            .catch { _ in
                Observable<[Repository]?>.just(nil)
            }
            .compactMap { $0 }
    }
}
