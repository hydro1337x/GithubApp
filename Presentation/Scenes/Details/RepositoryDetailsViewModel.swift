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
    }
    struct Output {
        let state: Driver<DataState<RepositoryDetailsModel>>
    }

    let ownerTitle = "Owner:"
    let createdAtTitle = "Created at:"
    let updatedAtTitle = "Updated at:"

    private let name: String
    private let owner: String
    private let fetchRepositoryDetailsUseCase: FetchRepositoryDetailsUseCase
    private let repositoryDetailsMapper: AnyMapper<RepositoryDetails, RepositoryDetailsModel>

    public init(
        name: String,
        owner: String,
        fetchRepositoryDetailsUseCase: FetchRepositoryDetailsUseCase,
        repositoryDetailsMapper: AnyMapper<RepositoryDetails, RepositoryDetailsModel>
    ) {
        self.name = name
        self.owner = owner
        self.fetchRepositoryDetailsUseCase = fetchRepositoryDetailsUseCase
        self.repositoryDetailsMapper = repositoryDetailsMapper
    }

    func transform(input: Input) -> Output {
        let partialState = input.trigger
            .asObservable()
            .flatMap { [unowned self] in
                fetchRepositoryDetailsUseCase.execute(with: FetchRepositoryDetailsInput(name: name, owner: owner))
                    .map(repositoryDetailsMapper.map(input:))
                    .asObservable()
                    .materialize()
                    .compactMap { event -> DataState<RepositoryDetailsModel>? in
                        switch event {
                        case .error(let error):
                            return .failed(error.localizedDescription)
                        case .next(let data):
                            return .loaded(data)
                        case .completed:
                            return nil
                        }
                    }
            }
            .share()

        let state = Observable<DataState<RepositoryDetailsModel>>
            .merge(
                input.trigger.asObservable().map { .loading },
                partialState
            )
            .startWith(.initial)

        return Output(state: state.asDriver(onErrorDriveWith: .empty()))
    }
}
