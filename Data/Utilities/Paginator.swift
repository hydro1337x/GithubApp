//
//  Paginator.swift
//  Data
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation

public final class Paginator<PageType> {
    let limit: Int
    private(set) var currentPage: Int
    private(set) var pages: [PageType] = []
    private var hasNextPage = true

    public init(limit: Int, initialPage: Int) {
        self.limit = limit
        self.currentPage = initialPage
    }

    func paginate(_ input: PaginatedResponse<PageType>) -> [PageType] {
        guard hasNextPage else {
            hasNextPage = false
            return pages
        }

        if currentPage * limit < input.pagination.total {
            currentPage += 1
            pages.append(contentsOf: input.page)
            return pages
        } else {
            return pages
        }
    }

    func resetPages() {
        currentPage = 1
        hasNextPage = true
        pages = []
    }
}
