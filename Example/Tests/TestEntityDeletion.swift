//
//  TestEntityDeletion.swift
//  EZCoreData_Tests
//
//  Created by Marcelo Salloum dos Santos on 05/02/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import CoreData
@testable import EZCoreData_Example
@testable import EZCoreData

class TestEntityDeletion: XCTestCase {

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

    // MARK: - Test Delete
    func testDeleteOne() {
        do {
            // Test Count and Save methods
            let initialCount = try Article.count(context: context)
            print(initialCount)
            let article = Article.getOrCreate(attribute: "id", value: "1234", context: context)
            try context.save()
            let countPP = try Article.count(context: context)
            print(countPP)
            XCTAssertEqual(initialCount + 1, countPP)

            // Test Delete and Count Methods
            try article?.delete(context: context)
            let finalCount = try Article.count(context: context)
            print(finalCount)
            XCTAssertEqual(countPP - 1, finalCount)
            XCTAssertEqual(initialCount, finalCount)
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func testDeleteAll() {
        try? Article.deleteAll(context: context)
        var countZero = try? Article.count(context: context)
        XCTAssertEqual(countZero, 0)

        _ = try? Article.importList(mockArticleListResponseJSON, idKey: "id", shouldSave: true, context: context)
        let countSix = try? Article.count(context: context)
        XCTAssertEqual(countSix, 6)

        try? Article.deleteAll(context: context)
        countZero = try? Article.count(context: context)
        XCTAssertEqual(countZero, 0)
    }

    func testDeleteSubset() {
        try? Article.deleteAll(context: context)
        let countZero = try? Article.count(context: context)
        XCTAssertEqual(countZero, 0)

        _ = try? Article.importList(mockArticleListResponseJSON, idKey: "id", shouldSave: true, context: context)
        let countSix = try? Article.count(context: context)
        XCTAssertEqual(countSix, 6)

        let remainingList = try? Article.readAll(predicate: NSPredicate(format: "id < 3"), context: context)
        let expectedCountSubset = remainingList?.count
        try? Article.deleteAll(except: remainingList, context: context)
        let countSubset = try? Article.count(context: context)
        XCTAssertEqual(countSubset, expectedCountSubset)
    }
}
