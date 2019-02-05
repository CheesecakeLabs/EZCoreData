//
//  TestEntityCreation.swift
//  EZCoreData_Tests
//
//  Created by Marcelo Salloum dos Santos on 05/02/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import CoreData
@testable import EZCoreData_Example
@testable import EZCoreData

class TestEntityCreation: XCTestCase {

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

    // MARK: - Test Create
    func testArticleCreation() {
        do {
            // Test Count and Save methods
            let initialCount = try Article.count(context: context)
            _ = Article.getOrCreate(attribute: "id", value: "1234", context: context)
            try context.save()
            let countPP = try Article.count(context: context)
            XCTAssertEqual(initialCount + 1, countPP)
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func testCreateAndSave() {
        let newArticle = Article.create(in: backgroundContext)
        var bckgCount = try? Article.count(context: backgroundContext) // Counts objects in the Background Context
        var fgndCount = try? Article.count(context: context) // Counts objects in the Foreground Context
        XCTAssertEqual(bckgCount!, fgndCount! + 1)

        newArticle?.managedObjectContext?.saveContextToStore()
        bckgCount = try? Article.count(context: backgroundContext)
        fgndCount = try? Article.count(context: context)
        XCTAssertEqual(bckgCount!, fgndCount!)
    }

    func testSave() {
        _ = Article.create(in: backgroundContext, shouldSave: true)
        let bckgCount = try? Article.count(context: backgroundContext) // Counts objects in the Background Context
        let fgndCount = try? Article.count(context: context) // Counts objects in the Foreground Context
        XCTAssertEqual(bckgCount!, fgndCount!)
    }
}
