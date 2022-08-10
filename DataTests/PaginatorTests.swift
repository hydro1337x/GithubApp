//
//  PaginatorTests.swift
//  PaginatorTests
//
//  Created by Benjamin Mecanović on 29.07.2022..
//

import XCTest
import RxSwift
import RxRelay
@testable import Data

class PaginatorTests: XCTestCase {

    func test_paginator_whenFirstPageHasLessElementsThanLimit() throws {
        let disposeBag = DisposeBag()
        let relay = PublishRelay<PaginatedResponse<Int>>()
        let sut = Paginator<Int>(limit: 5, initialPage: 1)

        relay
            .flatMap { response in
                sut.paginate(.just(response))
            }
            .subscribe()
            .disposed(by: disposeBag)

        relay.accept(makeMockedResponseWithModifiedLimit(page: sut.currentPage, limit: 5, total: 15, modifier: -1))
        XCTAssertEqual(sut.pages.count, 4)
        XCTAssertEqual(sut.currentPage, 2)
        relay.accept(makeMockedResponse(page: sut.currentPage, limit: 5, total: 15))
        XCTAssertEqual(sut.pages.count, 9)
        XCTAssertEqual(sut.currentPage, 3)
        relay.accept(makeMockedResponse(page: sut.currentPage, limit: 5, total: 15))
        XCTAssertEqual(sut.pages.count, 14)
        XCTAssertEqual(sut.currentPage, 3)
    }

    func test_paginator_whenLastPageHasLessElementsThanLimit() throws {
        let disposeBag = DisposeBag()
        let relay = PublishRelay<PaginatedResponse<Int>>()
        let sut = Paginator<Int>(limit: 5, initialPage: 1)

        relay
            .flatMap { response in
                sut.paginate(.just(response))
            }
            .subscribe()
            .disposed(by: disposeBag)

        relay.accept(makeMockedResponse(page: sut.currentPage, limit: 5, total: 15))
        XCTAssertEqual(sut.pages.count, 5)
        XCTAssertEqual(sut.currentPage, 2)
        relay.accept(makeMockedResponse(page: sut.currentPage, limit: 5, total: 15))
        XCTAssertEqual(sut.pages.count, 10)
        XCTAssertEqual(sut.currentPage, 3)
        relay.accept(makeMockedResponseWithModifiedLimit(page: sut.currentPage, limit: 5, total: 15, modifier: -1))
        XCTAssertEqual(sut.pages.count, 14)
        XCTAssertEqual(sut.currentPage, 3)
    }

    func test_paginator_whenLastPageIsEqualToLimit() throws {
        let disposeBag = DisposeBag()
        let relay = PublishRelay<PaginatedResponse<Int>>()
        let sut = Paginator<Int>(limit: 5, initialPage: 1)

        relay
            .flatMap { response in
                sut.paginate(.just(response))
            }
            .subscribe()
            .disposed(by: disposeBag)

        relay.accept(makeMockedResponse(page: sut.currentPage, limit: 5, total: 15))
        XCTAssertEqual(sut.pages.count, 5)
        XCTAssertEqual(sut.currentPage, 2)
        relay.accept(makeMockedResponse(page: sut.currentPage, limit: 5, total: 15))
        XCTAssertEqual(sut.pages.count, 10)
        XCTAssertEqual(sut.currentPage, 3)
        relay.accept(makeMockedResponse(page: sut.currentPage, limit: 5, total: 15))
        XCTAssertEqual(sut.pages.count, 15)
        XCTAssertEqual(sut.currentPage, 3)
    }

    func test_paginator_whenLastPageIsLessThanLimit() throws {
        let disposeBag = DisposeBag()
        let relay = PublishRelay<PaginatedResponse<Int>>()
        let sut = Paginator<Int>(limit: 5, initialPage: 1)

        relay
            .flatMap { response in
                sut.paginate(.just(response))
            }
            .subscribe()
            .disposed(by: disposeBag)

        relay.accept(makeMockedResponse(page: sut.currentPage, limit: 5, total: 14))
        XCTAssertEqual(sut.pages.count, 5)
        XCTAssertEqual(sut.currentPage, 2)
        relay.accept(makeMockedResponse(page: sut.currentPage, limit: 5, total: 14))
        XCTAssertEqual(sut.pages.count, 10)
        XCTAssertEqual(sut.currentPage, 3)
        relay.accept(makeMockedResponse(page: sut.currentPage, limit: 4, total: 14))
        XCTAssertEqual(sut.pages.count, 14)
        XCTAssertEqual(sut.currentPage, 3)
    }

    func test_resetState() {
        let disposeBag = DisposeBag()
        let relay = PublishRelay<PaginatedResponse<Int>>()
        let sut = Paginator<Int>(limit: 5, initialPage: 1)

        relay
            .flatMap { response in
                sut.paginate(.just(response))
            }
            .subscribe()
            .disposed(by: disposeBag)

        relay.accept(makeMockedResponse(page: sut.currentPage, limit: 5, total: 14))
        XCTAssertEqual(sut.pages.count, 5)
        XCTAssertEqual(sut.currentPage, 2)

        sut.resetState()
        XCTAssertEqual(sut.pages.count, 0)
        XCTAssertEqual(sut.currentPage, 1)

        relay.accept(makeMockedResponse(page: sut.currentPage, limit: 5, total: 14))
        XCTAssertEqual(sut.pages.count, 5)
        XCTAssertEqual(sut.currentPage, 2)
    }
}

extension PaginatorTests {
    func makeMockedResponse(page: Int, limit: Int, total: Int) -> PaginatedResponse<Int> {
        let page = Array(1...limit)
        let pagination = DefaultPagination(total: total)
        return PaginatedResponse(page: page, pagination: pagination)
    }

    func makeMockedResponseWithModifiedLimit(page: Int, limit: Int, total: Int, modifier: Int) -> PaginatedResponse<Int> {
        makeMockedResponse(page: page, limit: limit + modifier, total: total)
    }
}
