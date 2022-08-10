//
//  RepositoryDetailsViewModel.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 31.07.2022..
//

import Foundation
import RxSwift
import RxCocoa
import Domain

public final class RepositoryDetailsViewModel {
    struct Input {
        let favoriteTrigger: Signal<Void>
    }
    struct Output {
        let repositoryDetailsState: Driver<DataState<RepositoryDetailsModel>>
        let isFavoriteInitially: Driver<Bool>
        let isFavoriteToggleState: Driver<DataState<Bool>>
    }

    let createdAtTitle = "Created at:"
    let updatedAtTitle = "Updated at:"

    private let name: String
    private let owner: String
    private let fetchRepositoryDetailsUseCase: FetchRepositoryDetailsUseCase
    private let toggleFavoriteRepositoryUseCase: ToggleFavoriteRepositoryUseCase
    private let checkIfRepositoryIsFavoriteUseCase: CheckIfRepositoryIsFavoriteUseCase
    private let repositoryDetailsToRepositoryDetailsModelMapper: AnyMapper<RepositoryDetails, RepositoryDetailsModel>
    private let scheduler: SchedulerType

    public init(
        name: String,
        owner: String,
        fetchRepositoryDetailsUseCase: FetchRepositoryDetailsUseCase,
        toggleFavoriteRepositoryUseCase: ToggleFavoriteRepositoryUseCase,
        checkIfRepositoryIsFavoriteUseCase: CheckIfRepositoryIsFavoriteUseCase,
        repositoryDetailsToRepositoryDetailsModelMapper: AnyMapper<RepositoryDetails, RepositoryDetailsModel>,
        scheduler: SchedulerType
    ) {
        self.name = name
        self.owner = owner
        self.fetchRepositoryDetailsUseCase = fetchRepositoryDetailsUseCase
        self.toggleFavoriteRepositoryUseCase = toggleFavoriteRepositoryUseCase
        self.checkIfRepositoryIsFavoriteUseCase = checkIfRepositoryIsFavoriteUseCase
        self.repositoryDetailsToRepositoryDetailsModelMapper = repositoryDetailsToRepositoryDetailsModelMapper
        self.scheduler = scheduler
    }

    func transform(input: Input) -> Output {
        var toggle = false

        let fetchRepositoryDetailsInput = FetchRepositoryDetailsInput(name: name, owner: owner)
        let repositoryDetailsPartialState = fetchRepositoryDetailsUseCase.execute(with: fetchRepositoryDetailsInput)
            .map(repositoryDetailsToRepositoryDetailsModelMapper.map(input:))
            .map { DataState.loaded($0) }
            .catch { error in
                .just(.failed(error.localizedDescription))
            }
            .asObservable()

        let repositoryDetailsState = Observable
            .merge(
                .just(.loading),
                repositoryDetailsPartialState
            )
            .startWith(.initial)

        let debouncedFavoriteTrigger = input.favoriteTrigger
            .asObservable()
            .delay(.milliseconds(500), scheduler: scheduler)
            .observe(on: scheduler)

        let isFavoriteTogglePartialState = debouncedFavoriteTrigger
            .map { [unowned self] in
                let fetchRepositoryDetailsInput = FetchRepositoryDetailsInput(name: name, owner: owner)
                return ToggleFavoriteRepositoryInput(
                    toggle: toggle,
                    fetchRepositoryDetailsInput: fetchRepositoryDetailsInput
                )
            }
            .flatMap { [unowned self] input -> Observable<DataState<Bool>> in
                toggleFavoriteRepositoryUseCase.execute(input: input)
                    .andThen(Observable<Void>.just(()))
                    .do(onNext: {
                        toggle = !toggle
                    })
                    .map { .loaded(toggle) }
                    .catch { error in
                        .just(.failed(error.localizedDescription))
                    }
            }
            .share()

        let isFavoriteToggleState = Observable
            .merge(
                debouncedFavoriteTrigger.map { _ in DataState<Bool>.loading },
                isFavoriteTogglePartialState
            )
            .startWith(.initial)

        let findRepositoryInput = FindRepositoryInput(name: name, owner: owner)
        let IsFavoriteInitially = checkIfRepositoryIsFavoriteUseCase.execute(input: findRepositoryInput)
            .do(onSuccess: { value in
                toggle = value
            })
            .catchAndReturn(false)

        return Output(
            repositoryDetailsState: repositoryDetailsState.asDriver(onErrorDriveWith: .empty()),
            isFavoriteInitially: IsFavoriteInitially.asDriver(onErrorDriveWith: .empty()),
            isFavoriteToggleState: isFavoriteToggleState.asDriver(onErrorDriveWith: .empty())
        )
    }
}
