//
//  TestEZCoreData.swift
//  CKL iOS Challenge Tests
//
//  Created by Marcelo Salloum dos Santos on 21/01/19.
//  Copyright © 2019 Marcelo Salloum dos Santos. All rights reserved.
//

import XCTest
@testable import EZCoreData_Example

// MARK: - Mocking Core Data:
class TestEntityRead: EZTestCase {

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCount() {
        do {
            let articleCount = try Article.count(context: context)
            XCTAssertNotNil(articleCount)
            let tagCount = try Tag.count(context: context)
            XCTAssertNotNil(tagCount)
        } catch let error {
            print(error)
        }
    }

    // MARK: - Test Read
    func testReadAll() {
        try? Article.deleteAll(context: context)
        _ = try? Article.importList(mockArticleListResponseJSON, idKey: "id", shouldSave: true, context: context)
        let articles = try? Article.readAll(context: context)
        XCTAssertEqual(articles?.count, 6)
    }

    func testReadByAttribute() {
        _ = try? Article.importList(mockArticleListResponseJSON, idKey: "id", shouldSave: true, context: context)
        let articles = try? Article.readAllByAttribute("title", value: "Art", context: context)
        XCTAssertEqual(articles?.count, 2)
    }

    func testReadAllAsync() {
        // Initial SetuUp
        try? Article.deleteAll(context: context)
        _ = try? Article.importList(mockArticleListResponseJSON, idKey: "id", shouldSave: true, context: context)
        var articles: [Article] = []

        // Creating expectations
        let successExpectation = self.expectation(description: "testReadAllAsync_success")
        let failureExpectation = self.expectation(description: "testReadAllAsync_failure")
        failureExpectation.isInverted = true

        // Performs the test
        Article.readAll(context: context) { (result) in
            switch result {
            case .success(result: let articleList):
                guard let articleList = articleList else { failureExpectation.fulfill(); return }
                articles = articleList
                successExpectation.fulfill()
            case .failure(error: _):
                failureExpectation.fulfill()
            }
        }

        // Waits for the expectations
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(articles.count, 6)
    }

    // MARK: - Test Read First
    func testReadFirst() {
        do {
            try? Article.deleteAll(context: context)
            _ = try Article.importList(mockArticleListResponseJSON, idKey: "id", shouldSave: true, context: context)
            let randId = Int16.random(in: 1 ... 6)
            let article = try Article.readFirst(NSPredicate(format: "id == \(randId)"), context: context)
            XCTAssertEqual(article!.id, randId)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
