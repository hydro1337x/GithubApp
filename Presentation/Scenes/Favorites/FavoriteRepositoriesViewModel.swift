//
//  FavoriteRepositoriesViewModel.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 06.08.2022..
//

import Foundation
import RxSwift
import RxCocoa
import Domain
import RxFeedback

public final class FavoriteRepositoriesViewModel {
    private let fetchFavoriteRepositoriesUseCase: FetchFavoriteRepositoriesUseCase
    private let repositoriesToRepositoryViewModelsMapper: AnyMapper<[Repository], [RepositoryViewModel]>
    private let scheduler: SchedulerType

    func state(with bindings: @escaping (Driver<State>) -> Signal<Event>) -> Driver<State> {
        Driver.system(
            initialState: .initial,
            reduce: State.reduce(state:event:),
            feedback:
                bindings,
                react(request: { $0.startLoading }, effects: { [unowned self] _ in
                    fetchFavoriteRepositoriesUseCase.execute()
                        .asObservable()
                        .observe(on: scheduler)
                        .map(repositoriesToRepositoryViewModelsMapper.map(input:))
                        .map { repositories in .loaded(repositories) }
                        .asSignal { error in
                            .just(.failed(error.localizedDescription))
                        }
            }))
    }

    public init(
        fetchFavoriteRepositoriesUseCase: FetchFavoriteRepositoriesUseCase,
        repositoriesToRepositoryViewModelsMapper: AnyMapper<[Repository], [RepositoryViewModel]>,
        scheduler: SchedulerType
    ) {
        self.fetchFavoriteRepositoriesUseCase = fetchFavoriteRepositoriesUseCase
        self.repositoriesToRepositoryViewModelsMapper = repositoriesToRepositoryViewModelsMapper
        self.scheduler = scheduler
    }
}

extension FavoriteRepositoriesViewModel {
    enum State: Equatable {
        case initial
        case loading
        case failed(String)
        case loaded([RepositoryViewModel])
    }

    enum Event: Equatable {
        case load
        case failed(String)
        case loaded([RepositoryViewModel])
    }

    struct Request: Equatable {}
}

extension FavoriteRepositoriesViewModel.State {
    static func reduce(state: Self, event: FavoriteRepositoriesViewModel.Event) -> Self {
        switch event {
        case .load:
            return .loading
        case .failed(let error):
            return .failed(error)
        case .loaded(let repositoryDetails):
            return .loaded(repositoryDetails)
        }
    }

    var startLoading: FavoriteRepositoriesViewModel.Request? {
        return self == .loading ? FavoriteRepositoriesViewModel.Request() : nil
    }
}
