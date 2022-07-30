//
//  Paginator.swift
//  Data
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation

public final class Paginator<PageType> {
    let limit: Int
    private(set) var currentPage = 0
    private var hasNextPage = true
    private var pages: [PageType] = []

    public init(limit: Int) {
        self.limit = limit
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

    func resetState() {
        currentPage = 0
        hasNextPage = true
        pages = []
    }
}
