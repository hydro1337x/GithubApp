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
        let trigger: Signal<Void>
        let favoriteTrigger: Signal<Void>
    }
    struct Output {
        let repositoryDetailsState: Driver<DataState<RepositoryDetailsModel>>
        let isFavoritedState: Driver<DataState<Bool>>
    }

    let createdAtTitle = "Created at:"
    let updatedAtTitle = "Updated at:"

    private let name: String
    private let owner: String
    private let fetchRepositoryDetailsUseCase: FetchRepositoryDetailsUseCase
    private let addFavoriteRepositoryUseCase: AddFavoriteRepositoryUseCase
    private let repositoryDetailsToRepositoryDetailsModelMapper: AnyMapper<RepositoryDetails, RepositoryDetailsModel>
    private let repositoryDetailsModelToRepositoryDetailsMapper: AnyMapper<RepositoryDetailsModel, RepositoryDetails>
    private let scheduler: SchedulerType

    public init(
        name: String,
        owner: String,
        fetchRepositoryDetailsUseCase: FetchRepositoryDetailsUseCase,
        addFavoriteRepositoryUseCase: AddFavoriteRepositoryUseCase,
        repositoryDetailsToRepositoryDetailsModelMapper: AnyMapper<RepositoryDetails, RepositoryDetailsModel>,
        repositoryDetailsModelToRepositoryDetailsMapper: AnyMapper<RepositoryDetailsModel, RepositoryDetails>,
        scheduler: SchedulerType
    ) {
        self.name = name
        self.owner = owner
        self.fetchRepositoryDetailsUseCase = fetchRepositoryDetailsUseCase
        self.addFavoriteRepositoryUseCase = addFavoriteRepositoryUseCase
        self.repositoryDetailsToRepositoryDetailsModelMapper = repositoryDetailsToRepositoryDetailsModelMapper
        self.repositoryDetailsModelToRepositoryDetailsMapper = repositoryDetailsModelToRepositoryDetailsMapper
        self.scheduler = scheduler
    }

    func transform(input: Input) -> Output {
        var repositoryDetailsModel: RepositoryDetailsModel?

        let repositoryDetailsPartialState = input.trigger
            .asObservable()
            .flatMap { [unowned self] in
                fetchRepositoryDetailsUseCase.execute(with: FetchRepositoryDetailsInput(name: name, owner: owner))
                    .map(repositoryDetailsToRepositoryDetailsModelMapper.map(input:))
                    .asObservable()
                    .materialize()
            }
            .compactMap { event -> DataState<RepositoryDetailsModel>? in
                switch event {
                case .error(let error):
                    return .failed(error.localizedDescription)
                case .next(let value):
                    repositoryDetailsModel = value
                    return .loaded(value)
                case .completed:
                    return nil
                }
            }
            .share()

        let repositoryDetailsState = Observable
            .merge(
                input.trigger.asObservable().map { DataState.loading },
                repositoryDetailsPartialState
            )
            .startWith(.initial)

        let debouncedFavoriteTrigger = input.favoriteTrigger
            .asObservable()
            .delay(.milliseconds(500), scheduler: scheduler)


        let isFavoritedPartialState = debouncedFavoriteTrigger
            .observe(on: scheduler)
            .compactMap { repositoryDetailsModel }
            .map { [unowned self] input in
                repositoryDetailsModelToRepositoryDetailsMapper.map(input: input)
            }
            .flatMap { [unowned self] input in
                addFavoriteRepositoryUseCase.execute(input: input)
                    .andThen(Observable<Bool>.just(true))
                    .materialize()
            }
            .compactMap { event -> DataState<Bool>? in
                switch event {
                case .next(let value):
                    return .loaded(value)
                case .error(let error):
                    return .failed(error.localizedDescription)
                case .completed:
                    return nil
                }
            }

        let isFavoritedState = Observable
            .merge(
                debouncedFavoriteTrigger.map { _ in DataState<Bool>.loading },
                isFavoritedPartialState
            )
            .startWith(.initial)

        return Output(
            repositoryDetailsState: repositoryDetailsState.asDriver(onErrorDriveWith: .empty()),
            isFavoritedState: isFavoritedState.asDriver(onErrorDriveWith: .empty())
        )
    }
}
