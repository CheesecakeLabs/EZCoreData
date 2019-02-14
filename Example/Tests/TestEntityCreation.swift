//
//  TestEntityCreation.swift
//  EZCoreData_Tests
//
//  Created by Marcelo Salloum dos Santos on 05/02/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import EZCoreData_Example

class TestEntityCreation: EZTestCase {

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
