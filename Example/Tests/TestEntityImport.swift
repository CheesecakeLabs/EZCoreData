//
//  TestEntityImport.swift
//  EZCoreData_Tests
//
//  Created by Marcelo Salloum dos Santos on 05/02/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import CoreData
@testable import EZCoreData
@testable import EZCoreData_Example

class TestEntityImport: EZTestCase {

    // MARK: - Entity missing `populateFromJSON` Method
    func testFatalIfEntityMissingMethod() {
        self.expectFatalError(expectedMessage: FatalMeessage.missingMethodOverride) {
            let fatalErrorEntity = FatalErrorEntity.create(in: self.context, shouldSave: true)
            fatalErrorEntity?.populateFromJSON([String: Any](), context: self.context)
        }
    }

    // MARK: - Test Import Objects
    func testImportObjectSync() {
        try? Article.deleteAll(context: context)
        let countZero = try? Article.count(context: context)
        XCTAssertEqual(countZero, 0)

        _ = try? Article.importObject(mockArticleListResponseJSON[0], shouldSave: false, context: context)
        _ = try? Article.importObject(mockArticleListResponseJSON[1], shouldSave: true, context: context)
        let countSix = try? Article.count(context: context)
        XCTAssertEqual(countSix, 2)
    }

    // MARK: - Test Import Objects ERRORs
    func testImportObjectNilJSONError() {
        XCTAssertThrowsError(try Article.importObject(nil, idKey: "a", shouldSave: true, context: context)) { error in
            XCTAssertEqual(error as? EZCoreDataError, EZCoreDataError.jsonIsEmpty)
        }
    }

    func testImportObjectInvalidIdKeyError() {
        let obj = mockArticleListResponseJSON[0]
        XCTAssertThrowsError(try Article.importObject(obj, idKey: "a", shouldSave: true, context: context)) { error in
            XCTAssertEqual(error as? EZCoreDataError, EZCoreDataError.invalidIdKey)
        }
    }

    // MARK: - Import List Sync
    func testImportListSync() {
        try? Article.deleteAll(context: context)
        let countZero = try? Article.count(context: context)
        XCTAssertEqual(countZero, 0)

        _ = try? Article.importList(mockArticleListResponseJSON, idKey: "id", shouldSave: true, context: context)
        let countSix = try? Article.count(context: context)
        XCTAssertEqual(countSix, 6)
    }

    func testIfImportDoesntDuplicaate() {
        do {
            let firstCount = try Article.count(context: context)
            importAllArticles()
            let secondCount = try Article.count(context: context)
            XCTAssertEqual(firstCount, secondCount)
        } catch let error {
            XCTAssertNil(error)
        }
    }

    // MARK: - Import List Errors
    func testImportListNilJSONError() {
        XCTAssertThrowsError(try Article.importList(nil, idKey: "a", shouldSave: true, context: context)) { error in
            XCTAssertEqual(error as? EZCoreDataError, EZCoreDataError.jsonIsEmpty)
        }
    }

    func testImportListEmptyJSONError() {
        let emptyList = [[String: Any]]()
        XCTAssertThrowsError(try Article.importList(emptyList, idKey: "a", shouldSave: true, context: context)) { err in
            XCTAssertEqual(err as? EZCoreDataError, EZCoreDataError.jsonIsEmpty)
        }
    }

    // MARK: - Import List Async
    func testImportListAsync() {
        // Initial SetuUp
        try? Article.deleteAll(context: context)
        let countZero = try? Article.count(context: context)
        XCTAssertEqual(countZero, 0)

        // Creating expectations
        let successExpectation = self.expectation(description: "testImportAsync_success")
        let failureExpectation = self.expectation(description: "testImportAsync_failure")
        failureExpectation.isInverted = true

        Article.importList(mockArticleListResponseJSON, idKey: "id", backgroundContext: context) { result in
            switch result {
            case .success(result: _):
                successExpectation.fulfill()
                let countSix = try? Article.count(context: self.context)
                XCTAssertEqual(countSix, 6)
            case .failure(error: _):
                failureExpectation.fulfill()
            }
        }

        // Waits for the expectations
        waitForExpectations(timeout: 0.5, handler: nil)
    }

    // MARK: - Import List Async
    func testImportListAsyncWithoutIdKey() {
        // Initial SetuUp
        try? Article.deleteAll(context: backgroundContext)
        let countZero = try? Article.count(context: backgroundContext)
        XCTAssertEqual(countZero, 0)

        // Creating expectations
        let successExpectation = self.expectation(description: "testImportAsync_success")
        let failureExpectation = self.expectation(description: "testImportAsync_failure")
        failureExpectation.isInverted = true

        Article.importList(mockArticleListResponseJSON, backgroundContext: backgroundContext) { result in
            switch result {
            case .success(result: _):
                let countSix = try? Article.count(context: self.backgroundContext)
                XCTAssertEqual(countSix, 6)

                Article.importList(mockArticleListResponseJSON, backgroundContext: self.backgroundContext) { result2 in
                    switch result2 {
                    case .success(result: _):
                        let countTwelve = try? Article.count(context: self.backgroundContext)
                        XCTAssertEqual(countTwelve, 12)
                        successExpectation.fulfill()
                    case .failure(error: _):
                        failureExpectation.fulfill()
                    }
                }

            case .failure(error: _):
                failureExpectation.fulfill()
            }
        }

        // Waits for the expectations
        waitForExpectations(timeout: 0.5, handler: nil)
    }

    // MARK: - Import List Async ERRORs
    func testAsyncImportListNilJSONError() {
        validateAsyncImport(json: nil, idKey: "", error: .jsonIsEmpty)
    }

    func testAsyncImportListEmptyJSONError() {
        validateAsyncImport(json: [[String: Any]](), idKey: "", error: .jsonIsEmpty)
    }

    func testAsyncImportListInvalidIdKeyError() {
        let obj = mockArticleListResponseJSON[0]
        validateAsyncImport(json: [obj], idKey: "a", error: .invalidIdKey)
    }

    /// Convenience method used in order to avoid repeeating code
    fileprivate func validateAsyncImport(json: [[String: Any]]?, idKey: String, error: EZCoreDataError) {
        let randomInt = Int.random(in: 0...10000)
        let successExpectation = self.expectation(description: "\(randomInt)validateImport_success")
        successExpectation.isInverted = true
        let failureExpectation = self.expectation(description: "\(randomInt)validateImport_failure")

        Article.importList(json, idKey: idKey, backgroundContext: backgroundContext) { (result) in

            switch result {
            case .success(result: _):
                successExpectation.fulfill()
            case .failure(error: let e):
                failureExpectation.fulfill()
                XCTAssertEqual(e as? EZCoreDataError, error)
            }
        }

        // Waits for the expectations
        waitForExpectations(timeout: 0.5, handler: nil)
    }
}
