//
//  SearchRepositoriesViewModel.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation
import Domain
import RxSwift
import RxCocoa
import RxFeedback

public final class SearchRepositoriesViewModel {
    private let fetchSearchedRepositoriesUseCase: FetchSearchedRepositoriesUseCase
    private let repositoriesToRepositoryViewModelsMapper: AnyMapper<[Repository], [RepositoryViewModel]>
    private let scheduler: SchedulerType

    public init(
        fetchSearchedRepositoriesUseCase: FetchSearchedRepositoriesUseCase,
        repositoriesToRepositoryViewModelsMapper: AnyMapper<[Repository], [RepositoryViewModel]>,
        scheduler: SchedulerType
    ) {
        self.fetchSearchedRepositoriesUseCase = fetchSearchedRepositoriesUseCase
        self.repositoriesToRepositoryViewModelsMapper = repositoriesToRepositoryViewModelsMapper
        self.scheduler = scheduler
    }

    func state(with bindings: @escaping (Driver<State>) -> Signal<Event>) -> Driver<State> {
        Driver.system(
            initialState: .empty,
            reduce: State.reduce(state:event:),
            feedback:
                bindings,
                react(request: { $0.loadIfNeeded }, effects: { [unowned self] input in
                    fetchSearchedRepositoriesUseCase.execute(with: input)
                        .asObservable()
                        .observe(on: scheduler)
                        .map(repositoriesToRepositoryViewModelsMapper.map(input:))
                        .map { Event.loaded($0) }
                        .asSignal { error in
                            .just(Event.failed(error.localizedDescription))
                        }
            }))
    }
}

extension SearchRepositoriesViewModel {
    struct State {
        var search: String
        var shouldLoad: Bool
        var isInitialFetch: Bool
        var items: [SearchRepositoriesItem]
        var isLoading: Bool
        var isRefreshing: Bool
        var isSearching: Bool
        var failureMessage: String?
    }

    enum Event {
        case searchChanged(String)
        case refresh
        case bottomReached
        case failed(String)
        case loaded([RepositoryViewModel])
    }
}

extension SearchRepositoriesViewModel.State {
    static var empty: Self {
        return Self(
            search: "",
            shouldLoad: true,
            isInitialFetch: true,
            items: [],
            isLoading: false,
            isRefreshing: false,
            isSearching: false,
            failureMessage: nil
        )
    }

    static func reduce(state: Self, event: SearchRepositoriesViewModel.Event) -> Self {
        switch event {
        case .searchChanged(let search):
            var result = state
            result.search = search
            result.isInitialFetch = true
            result.shouldLoad = true
            result.isSearching = true
            return result
        case .refresh:
            var result = state
            result.isInitialFetch = true
            result.shouldLoad = true
            result.isRefreshing = true
            return result
        case .bottomReached:
            var result = state
            result.isInitialFetch = false
            result.shouldLoad = true
            if !result.isLoading {
                result.items.append(.activity)
            }
            result.isLoading = true
            return result
        case .loaded(let repositories):
            var result = state
            result.isLoading = false
            result.items = result.items.filter { $0 != .activity }
            result.items = repositories.map { SearchRepositoriesItem.item($0) }
            result.shouldLoad = false
            result.failureMessage = nil
            result.isRefreshing = false
            result.isSearching = false
            return result
        case .failed(let message):
            var result = state
            result.isLoading = false
            result.items = result.items.filter { $0 != .activity }
            result.shouldLoad = false
            result.failureMessage = message
            result.isRefreshing = false
            result.isSearching = false
            return result
        }
    }

    var loadIfNeeded: FetchRepositoriesInput? {
        shouldLoad ? FetchRepositoriesInput(searchInput: search, isInitialFetch: isInitialFetch) : nil
    }
}
