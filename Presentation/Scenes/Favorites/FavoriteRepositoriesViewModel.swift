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

public final class FavoriteRepositoriesViewModel {
    struct Input {
        let trigger: Driver<Void>
    }

    struct Output {
        let state: Driver<DataState<[RepositoryViewModel]>>
    }

    private let fetchFavoriteRepositoriesUseCase: FetchFavoriteRepositoriesUseCase
    private let repositoriesToRepositoryViewModelsMapper: AnyMapper<[Repository], [RepositoryViewModel]>
    private let scheduler: SchedulerType

    public init(
        fetchFavoriteRepositoriesUseCase: FetchFavoriteRepositoriesUseCase,
        repositoriesToRepositoryViewModelsMapper: AnyMapper<[Repository], [RepositoryViewModel]>,
        scheduler: SchedulerType
    ) {
        self.fetchFavoriteRepositoriesUseCase = fetchFavoriteRepositoriesUseCase
        self.repositoriesToRepositoryViewModelsMapper = repositoriesToRepositoryViewModelsMapper
        self.scheduler = scheduler
    }

    func transform(input: Input) -> Output {
        let trigger = input.trigger
            .asObservable()
            .observe(on: scheduler)

        let partialState = trigger
            .flatMap { [unowned self] in
                fetchFavoriteRepositoriesUseCase.execute()
                    .map(repositoriesToRepositoryViewModelsMapper.map(input:))
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
                trigger.map { _ in DataState.loading },
                partialState
            )
            .startWith(.initial)

        return Output(
            state: state.asDriver(onErrorDriveWith: .empty())
        )
    }
}
