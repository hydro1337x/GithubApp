//
//  FavoritesViewModel.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 06.08.2022..
//

import Foundation
import RxSwift
import RxCocoa
import Domain

public final class FavoritesViewModel {
    struct Input {
        let trigger: Signal<Void>
    }

    struct Output {
        let state: Driver<DataState<[RepositoryViewModel]>>
    }

    private let fetchFavoriteRepositoriesUseCase: FetchFavoriteRepositoriesUseCase
    private let repositoryListMapper: AnyMapper<[Repository], [RepositoryViewModel]>
    private let scheduler: SchedulerType

    public init(
        fetchFavoriteRepositoriesUseCase: FetchFavoriteRepositoriesUseCase,
        repositoryListMapper: AnyMapper<[Repository], [RepositoryViewModel]>,
        scheduler: SchedulerType
    ) {
        self.fetchFavoriteRepositoriesUseCase = fetchFavoriteRepositoriesUseCase
        self.repositoryListMapper = repositoryListMapper
        self.scheduler = scheduler
    }

    func transform(input: Input) -> Output {

        let partialState = input.trigger
            .asObservable()
            .observe(on: scheduler)
            .flatMap { [unowned self] in
                fetchFavoriteRepositoriesUseCase.execute()
                    .map(repositoryListMapper.map(input:))
                    .asObservable()
                    .materialize()
            }
            .compactMap { event -> DataState<[RepositoryViewModel]>? in
                switch event {
                case .next(let data):
                    return .loaded(data)
                case .error(let error):
                    return .failed(error.localizedDescription)
                case .completed:
                    return nil
                }
            }

        let state = Observable
            .merge(
                input.trigger.asObservable().map { _ in DataState.loading },
                partialState
            )
            .startWith(.initial)

        return Output(
            state: state.asDriver(onErrorDriveWith: .empty())
        )
    }
}
