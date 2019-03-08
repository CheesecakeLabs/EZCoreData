//
//  TestEntityDeletion.swift
//  EZCoreData_Tests
//
//  Created by Marcelo Salloum dos Santos on 05/02/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import EZCoreData_Example

class TestEntityDeletion: EZTestCase {

    // MARK: - Test Delete
    func testDeleteOne() {
        do {
            // Test Count and Save methods
            let initialCount = try Article.count(context: context)
            print(initialCount)
            let article = Article.getOrCreate(attribute: "id", value: 1234, context: context)
            try context.save()
            let countPP = try Article.count(context: context)
            XCTAssertEqual(initialCount + 1, countPP)

            // Test Delete and Count Methods
            try article?.delete(context: context)
            let finalCount = try Article.count(context: context)
            XCTAssertEqual(countPP - 1, finalCount)
            XCTAssertEqual(initialCount, finalCount)
        } catch let error {
            print(error.localizedDescription)
        }
    }

    // MARK: - Delee All
    func testDeleteAllSync() {
        eraseAllArticles()
    }

    func testDeleteAllAsync() {
        let successExpectation = self.expectation(description: "testDeleteAllAsync_success")
        let failureExpectation = self.expectation(description: "testDeleteAllAsync_failure")
        failureExpectation.isInverted = true

        Article.deleteAll(backgroundContext: backgroundContext) { result in
            switch result {
            case .success(result: _):
                let countSubset = try? Article.count(context: self.backgroundContext)
                XCTAssertEqual(countSubset, 0)
                successExpectation.fulfill()
            case .failure(error: _):
                failureExpectation.fulfill()
            }
        }

        // Waits for the expectations
        waitForExpectations(timeout: 0.5, handler: nil)
    }

    // MARK: - Delete All EXCEPT
    /// Delete All EXCEPT Sync
    func testDeleteExceptSubsetSync() {
        let remainingPredicate = NSPredicate(format: "id IN %@", NSArray(array: [1, 2]))
        let remainingList = try? Article.readAll(predicate: remainingPredicate, context: context)
        let expectedCountSubset = 2
        XCTAssertEqual(remainingList?.count, expectedCountSubset)

        try? Article.deleteAll(except: remainingList, context: context)
        let countSubset = try? Article.count(context: context)
        XCTAssertEqual(countSubset, expectedCountSubset)
    }

    /// Delete All EXCEPT Async
    func testDeleteExceptSubsetAsync() {
        let remainingPredicate = NSPredicate(format: "id IN %@", NSArray(array: [1, 2]))
        let remainingList = try? Article.readAll(predicate: remainingPredicate, context: context)
        let expectedCountSubset = 2
        XCTAssertEqual(remainingList?.count, expectedCountSubset)

        let successExpectation = self.expectation(description: "testDeleteExceptSubsetAsync_success")
        let failureExpectation = self.expectation(description: "testDeleteExceptSubsetAsync_failure")
        failureExpectation.isInverted = true

        Article.deleteAll(except: remainingList, backgroundContext: backgroundContext) { result in
            switch result {
            case .success(result: _):
                let countSubset = try? Article.count(context: self.backgroundContext)
                XCTAssertEqual(countSubset, expectedCountSubset)
                successExpectation.fulfill()
            case .failure(error: _):
                failureExpectation.fulfill()
            }
        }

        // Waits for the expectations
        waitForExpectations(timeout: 0.5, handler: nil)
    }

    // MARK: - Delete From List
    /// Delete All EXCEPT Sync
    func testDeleteFromSubsetSync() {
        let excludePredicate = NSPredicate(format: "id IN %@", NSArray(array: [1, 2]))
        let excludeList = try? Article.readAll(predicate: excludePredicate, context: context)
        XCTAssertEqual(excludeList?.count, 2)

        try? Article.deleteObjects(fromList: excludeList!, context)
        let countSubset = try? Article.count(context: context)
        XCTAssertEqual(countSubset, 4)
    }

    /// Delete All EXCEPT Async
    func testDeleteFromSubsetAsync() {
        let excludePredicate = NSPredicate(format: "id IN %@", NSArray(array: [1, 2]))
        let excludeList = try? Article.readAll(predicate: excludePredicate, context: backgroundContext)
        XCTAssertEqual(excludeList?.count, 2)

        let successExpectation = self.expectation(description: "testDeleteFromSubsetAsync_success")
        let failureExpectation = self.expectation(description: "testDeleteFromSubsetAsync_failure")
        failureExpectation.isInverted = true

        Article.deleteObjects(fromList: excludeList!, backgroundContext, completion: { result in
            switch result {
            case .success(result: _):
                let countSubset = try? Article.count(context: self.backgroundContext)
                XCTAssertEqual(countSubset, 4)
                successExpectation.fulfill()
            case .failure(error: _):
                failureExpectation.fulfill()
            }
        })

        // Waits for the expectations
        waitForExpectations(timeout: 0.5, handler: nil)
    }
}
