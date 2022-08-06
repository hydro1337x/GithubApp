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

struct TriggerInput {
    let currentIndex: Int
    let lastIndex: Int
}

public final class SearchRepositoriesViewModel {
    struct Input {
        let searchTrigger: Signal<String?>
        let refreshTrigger: Signal<String?>
        let subsequentTrigger: Signal<String?>
    }

    struct Output {
        let items: Driver<[SearchRepositoriesItem]>
        let refreshActivity: Driver<Bool>
        let searchActivity: Driver<Bool>
        let failureMessage: Signal<String>
    }

    private let fetchRepositoryListUseCase: FetchRepositoryListUseCase
    private let repositoryListMapper: AnyMapper<[Repository], [RepositoryViewModel]>
    private let scheduler: SchedulerType

    public init(
        fetchRepositoryListUseCase: FetchRepositoryListUseCase,
        repositoryListMapper: AnyMapper<[Repository], [RepositoryViewModel]>,
        scheduler: SchedulerType
    ) {
        self.fetchRepositoryListUseCase = fetchRepositoryListUseCase
        self.repositoryListMapper = repositoryListMapper
        self.scheduler = scheduler
    }

    func transform(input: Input) -> Output {
        let failureTracker = FailureTracker()
        let refreshActivityTracker = ActivityTracker()
        let searchActivityTracker = ActivityTracker()
        let loadActivityTracker = ActivityTracker()
        var isSubsequentFetchInProgress = false

        let refreshTrigger = input.refreshTrigger.asObservable()

        let searchTrigger = input.searchTrigger
            .asObservable()
            .debounce(.milliseconds(500), scheduler: scheduler)

        let refreshedRepositories = refreshTrigger
            .observe(on: scheduler)
            .compactMap { $0 }
            .flatMap { [unowned self] input in
                fetchRepositoryListUseCase.execute(with: FetchRepositoryListInput(searchInput: input,
                                                                                  isInitialFetch: true))
                    .trackActivity(refreshActivityTracker)
                    .trackFailure(failureTracker)
                    .map { Optional($0) }
                    .catch { _ in
                        Observable<[Repository]?>.just(nil)
                    }
                    .compactMap { $0 }
            }
            .share()

        let searchedRepositories = searchTrigger
            .observe(on: scheduler)
            .compactMap { $0 }
            .flatMap { [unowned self] input in
                fetchRepositoryListUseCase.execute(with: FetchRepositoryListInput(searchInput: input,
                                                                                  isInitialFetch: true))
                    .trackActivity(searchActivityTracker)
                    .trackFailure(failureTracker)
                    .map { Optional($0) }
                    .catch { _ in
                        Observable<[Repository]?>.just(nil)
                    }
                    .compactMap { $0 }
            }
            .share()

        let subsequentRepositories = input.subsequentTrigger
            .asObservable()
            .observe(on: scheduler)
            .filter { _ in !isSubsequentFetchInProgress }
            .do(onNext: { _ in
                isSubsequentFetchInProgress = true
            })
            .compactMap { $0 }
            .flatMap { [unowned self] input in
                fetchRepositoryListUseCase.execute(with: FetchRepositoryListInput(searchInput: input,
                                                                                  isInitialFetch: false))
                    .trackActivity(loadActivityTracker)
                    .trackFailure(failureTracker)
                    .map { Optional($0) }
                    .catch { _ in
                        Observable<[Repository]?>.just(nil)
                    }
                    .compactMap { $0 }
            }
            .share()
            .do(onNext: { _ in
                isSubsequentFetchInProgress = false
            })


        let repositories = Observable.merge(refreshedRepositories, searchedRepositories, subsequentRepositories)
            .map { [unowned self] repositories in
                repositoryListMapper.map(input: repositories)
            }

        let items = Observable.combineLatest(repositories, loadActivityTracker.asObservable())
            .map { repositories, isLoading -> [SearchRepositoriesItem] in
                var items = repositories.map { SearchRepositoriesItem.item($0) }
                if isLoading {
                    items.append(SearchRepositoriesItem.activity)
                }
                return items
            }
            .asDriver(onErrorDriveWith: .empty())

        let refreshActivity = refreshActivityTracker.asDriver()
        let searchActivity = searchActivityTracker.asDriver()

        let failureMessage = failureTracker
            .map { $0.localizedDescription }
            .asSignal(onErrorSignalWith: .empty())

        return Output(
            items: items,
            refreshActivity: refreshActivity,
            searchActivity: searchActivity,
            failureMessage: failureMessage
        )
    }
}
