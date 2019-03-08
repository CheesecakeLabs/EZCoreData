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

    // MARK: - Test Read All
    func testReadAll() {
        let articles = try? Article.readAll(context: context)
        XCTAssertEqual(articles?.count, mockArticleListResponseJSON.count)
    }

    func testReadAllAsync() {
        // Creating expectations
        let successExpectation = self.expectation(description: "testReadAllAsync_success")
        let failureExpectation = self.expectation(description: "testReadAllAsync_failure")
        failureExpectation.isInverted = true

        // Performs the test
        Article.readAll(context: backgroundContext) { (result) in
            switch result {
            case .success(result: let articleList):
                XCTAssertEqual(articleList?.count, 6)
                successExpectation.fulfill()
            case .failure(error: _):
                failureExpectation.fulfill()
            }
        }

        // Waits for the expectations
        waitForExpectations(timeout: 0.5, handler: nil)
    }

    // MARK: - Test Read All from Predicate
    func testReadAllWithPredicate() {
        let predicate = NSPredicate(format: "id IN %@", [1, 2])
        let articles = try? Article.readAll(predicate: predicate, context: context)
        XCTAssertEqual(articles?.count, 2)
    }

    func testReadAllWithPredicateAsync() {
        // Creating expectations
        let successExpectation = self.expectation(description: "testReadAllWithPredicateAsync_success")
        let failureExpectation = self.expectation(description: "testReadAllWithPredicateAsync_failure")
        failureExpectation.isInverted = true

        // Performs the test
        let predicate = NSPredicate(format: "id IN %@", [1, 2])
        Article.readAll(predicate: predicate, context: context) { (result) in
            switch result {
            case .success(result: let articleList):
                XCTAssertEqual(articleList?.count, 2)
                successExpectation.fulfill()
            case .failure(error: _):
                failureExpectation.fulfill()
            }
        }

        // Waits for the expectations
        waitForExpectations(timeout: 0.5, handler: nil)
    }

    // MARK: - Test Read All By Attribute
    func testReadAllByAttribute() {
        let articles = try? Article.readAllByAttribute("title", value: "Art", context: context)
        XCTAssertEqual(articles?.count, 2)
    }

    func testReadAllByAttributeAsync() {
        let successExpectation = self.expectation(description: "testReadAllByAttributeAsync_success")
        let failureExpectation = self.expectation(description: "testReadAllByAttributeAsync_failure")
        failureExpectation.isInverted = true

        Article.readAllByAttribute("title", value: "Art", context: context) { (result) in
            switch result {
            case .success(result: let articleList):
                XCTAssertEqual(articleList?.count, 2)
                successExpectation.fulfill()
            case .failure(error: _):
                failureExpectation.fulfill()
            }
        }

        // Waits for the expectations
        waitForExpectations(timeout: 0.5, handler: nil)
    }

    // MARK: - Test Read First
    func testReadFirst() {
        do {
            let randId = Int16.random(in: 1 ... 6)
            let article = try Article.readFirst(NSPredicate(format: "id == \(randId)"), context: context)
            XCTAssertEqual(article!.id, randId)
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func testReadFirstWithAttribute() {
        do {
            let randId = Int.random(in: 1 ... 6)
//            let article = try Article.readFirst(attribute: "id", value: randId, context: context)
            if let article = try Article.readFirst(attribute: "id", value: randId, context: context) {
                XCTAssertEqual(article.id, Int16(randId))
            } else {
                XCTAssertTrue(false)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
