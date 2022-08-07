//
//  AddFavoriteRepositoryUseCaseDecorator.swift
//  GithubApp
//
//  Created by Benjamin Mecanović on 07.08.2022..
//

import Foundation
import Domain
import RxSwift
import RxRelay

final class AddFavoriteRepositoryUseCaseDecorator: AddFavoriteRepositoryUseCase {
    private let decoratee: AddFavoriteRepositoryUseCase
    private let completionRelay: PublishRelay<Void>

    init(_ decoratee: AddFavoriteRepositoryUseCase, completionRelay: PublishRelay<Void>) {
        self.decoratee = decoratee
        self.completionRelay = completionRelay
    }

    func execute(input: RepositoryDetails) -> Completable {
        decoratee.execute(input: input)
            .do(afterCompleted: { [weak self] in
                guard let self = self else { return }
                self.completionRelay.accept(())
            })
    }
}
