//
//  TestEntityImport.swift
//  EZCoreData_Tests
//
//  Created by Marcelo Salloum dos Santos on 05/02/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import CoreData
@testable import EZCoreData_Example
@testable import EZCoreData

class TestEntityImport: XCTestCase {

    override func setUp() {
        EZCoreData.shared.setupInMemoryPersistence("Model")
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    private var context: NSManagedObjectContext {
        return EZCoreData.shared.mainThreadContext
    }

    private var backgroundContext: NSManagedObjectContext {
        return EZCoreData.shared.privateThreadContext
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

}
