//
//  TestEntityImport.swift
//  EZCoreData_Tests
//
//  Created by Marcelo Salloum dos Santos on 05/02/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import EZCoreData
@testable import EZCoreData_Example

class TestEntityImport: EZTestCase {

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Test Import
    func testImportObjectSync() {
        try? Article.deleteAll(context: context)
        let countZero = try? Article.count(context: context)
        XCTAssertEqual(countZero, 0)

        _ = try? Article.importObject(mockArticleListResponseJSON[0], shouldSave: false, context: context)
        _ = try? Article.importObject(mockArticleListResponseJSON[1], shouldSave: true, context: context)
        let countSix = try? Article.count(context: context)
        XCTAssertEqual(countSix, 2)
    }

    func testImportListSync() {
        try? Article.deleteAll(context: context)
        let countZero = try? Article.count(context: context)
        XCTAssertEqual(countZero, 0)

        _ = try? Article.importList(mockArticleListResponseJSON, idKey: "id", shouldSave: true, context: context)
        let countSix = try? Article.count(context: context)
        XCTAssertEqual(countSix, 6)
    }

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
            case .failure(error: _):
                failureExpectation.fulfill()
            }
        }

        // Waits for the expectations
        waitForExpectations(timeout: 1, handler: nil)
        let countSix = try? Article.count(context: self.context)
        XCTAssertEqual(countSix, 6)
    }

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

    func testImportListNilJSONError() {
        XCTAssertThrowsError(try Article.importList(nil, idKey: "a", shouldSave: true, context: context)) { error in
            XCTAssertEqual(error as? EZCoreDataError, EZCoreDataError.jsonIsEmpty)
        }
    }

    func testImportListEmptyJSONError() {
        XCTAssertThrowsError(try Article.importList([[String: Any]](),
                                                    idKey: "a",
                                                    shouldSave: true,
                                                    context: context)) { error in
            XCTAssertEqual(error as? EZCoreDataError, EZCoreDataError.jsonIsEmpty)
        }
    }

    func testAsyncImportListNilJSONError() {
        let successExpectation = self.expectation(description: "asyncImportListEmptyJSONError_success")
        successExpectation.isInverted = true
        let failureExpectation = self.expectation(description: "asyncImportListEmptyJSONError_failure")

        Article.importList(nil, idKey: "", backgroundContext: backgroundContext) { (result) in

            switch result {
            case .success(result: _):
                successExpectation.fulfill()
            case .failure(error: let error):
                failureExpectation.fulfill()
                XCTAssertEqual(error as? EZCoreDataError, EZCoreDataError.jsonIsEmpty)
            }
        }

        // Waits for the expectations
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testAsyncImportListEmptyJSONError() {
        let successExpectation = self.expectation(description: "asyncImportListEmptyJSONError_success")
        successExpectation.isInverted = true
        let failureExpectation = self.expectation(description: "asyncImportListEmptyJSONError_failure")

        Article.importList([[String: Any]](), idKey: "", backgroundContext: backgroundContext) { (result) in

            switch result {
            case .success(result: _):
                successExpectation.fulfill()
            case .failure(error: let error):
                failureExpectation.fulfill()
                XCTAssertEqual(error as? EZCoreDataError, EZCoreDataError.jsonIsEmpty)
            }
        }

        // Waits for the expectations
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testAsyncImportObjectInvalidIdKeyError() {
        let successExpectation = self.expectation(description: "asyncImportObjectInvalidIdKeyError_success")
        successExpectation.isInverted = true
        let failureExpectation = self.expectation(description: "asyncImportObjectInvalidIdKeyError_failure")

        let obj = mockArticleListResponseJSON[0]
        Article.importList([obj], idKey: "a", backgroundContext: backgroundContext) { (result) in

            switch result {
            case .success(result: _):
                successExpectation.fulfill()
            case .failure(error: let error):
                failureExpectation.fulfill()
                XCTAssertEqual(error as? EZCoreDataError, EZCoreDataError.invalidIdKey)
            }
        }

        // Waits for the expectations
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testFatalIfEntityMissingMethod() {
        self.expectFatalError(expectedMessage: FatalMeessage.missingMethodOverride) {
            let fatalErrorEntity = FatalErrorEntity.create(in: self.context, shouldSave: true)
            fatalErrorEntity?.populateFromJSON([String: Any](), context: self.context)
        }
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
}
