//
//  Paginator.swift
//  Data
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation
import RxSwift

public final class Paginator<PageType> {
    let limit: Int
    private var hasNext = true
    private(set) var currentPage: Int
    private(set) var pages: [PageType] = []

    public init(limit: Int, initialPage: Int) {
        self.limit = limit
        self.currentPage = initialPage
    }

    func paginate(_ input: Single<PaginatedResponse<PageType>>) -> Single<[PageType]> {
        Single<Void>.just(())
            .flatMap { [weak self] in
                guard let self = self else { return .just([]) }
                return self.hasNext ? self.handlePagination(input) : .just(self.pages)
            }
    }

    private func handlePagination(_ input: Single<PaginatedResponse<PageType>>) -> Single<[PageType]> {
        input
            .do(onSuccess: { [weak self] response in
                guard let self = self else { return }
                self.handleState(for: response)
            })
            .map { [pages] response in
                var pages = pages
                pages.append(contentsOf: response.page)
                return pages
            }
            .do(onSuccess: { [weak self] pages in
                guard let self = self else { return }
                self.pages = pages
            })
    }

    private func handleState(for response: PaginatedResponse<PageType>) {
        guard
            currentPage * limit < response.pagination.total
        else {
            hasNext = false
            return
        }

        currentPage += 1
    }

    func resetState() {
        currentPage = 1
        hasNext = true
        pages = []
    }
}
