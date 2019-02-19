//
//  TestEntityCreation.swift
//  EZCoreData_Tests
//
//  Created by Marcelo Salloum dos Santos on 05/02/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import EZCoreData_Example
@testable import PromiseKit

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
        _ = Article.create(in: backgroundContext)
        backgroundContext.saveContextToStore()
        let bckgCount = try? Article.count(context: backgroundContext) // Counts objects in the Background Context
        let fgndCount = try? Article.count(context: context) // Counts objects in the Foreground Context
        XCTAssertEqual(bckgCount!, fgndCount!)
    }

    // MARK: - Test Create with Promises
    func testCreateAndAsycSaveInMainContext() {
        // Initial Counter
        let initialCount = (try? Article.count(context: context))!
        _ = Article.getOrCreate(attribute: "id", value: "1234", context: context)

        // Declares expectations
        let successExpectation = self.expectation(description: "testArticleCreationP_success")
        let failureExpectation = self.expectation(description: "testArticleCreationP_failure")
        failureExpectation.isInverted = true

        // Saves and tests results
        firstly {
            context.saveToStore()
        }.done {
            let countPP = try Article.count(context: self.context)
            XCTAssertEqual(initialCount + 1, countPP)
            successExpectation.fulfill()
        }.catch { _ in
            failureExpectation.fulfill()
        }

        // Waits for the expectations
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testCreateAndAsyncSaveInBckgContext() {
        _ = Article.create(in: backgroundContext)

        // Declares expectations
        let successExpectation = self.expectation(description: "testArticleCreationP_success")
        let failureExpectation = self.expectation(description: "testArticleCreationP_failure")
        failureExpectation.isInverted = true

        // Saves and tests results
        firstly {
            backgroundContext.saveToStore()
        }.done {
            let bckgCount = try Article.count(context: self.backgroundContext) // Counts objects in the Bckg Context
            let fgndCount = try Article.count(context: self.context) // Counts objects in the Fgnd Context
            XCTAssertEqual(bckgCount, fgndCount)
            successExpectation.fulfill()
        }.catch { _ in
            failureExpectation.fulfill()
        }

        // Waits for the expectations
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testBckgContextObjectWntReachMinContextUntilSave() {
        // Before saving, the object created in bckg context is not showing in fgnd context
        _ = Article.create(in: backgroundContext)
        var bckgCount = try? Article.count(context: backgroundContext) // Counts objects in the Background Context
        var fgndCount = try? Article.count(context: context) // Counts objects in the Foreground Context
        XCTAssertEqual(bckgCount!, fgndCount! + 1)

        // Declares expectations
        let successExpectation = self.expectation(description: "testArticleCreationP_success")
        let failureExpectation = self.expectation(description: "testArticleCreationP_failure")
        failureExpectation.isInverted = true

        // Saves and tests results
        firstly {
            backgroundContext.saveToStore()
        }.done {
            bckgCount = try Article.count(context: self.backgroundContext)
            fgndCount = try Article.count(context: self.context)
            XCTAssertEqual(bckgCount, fgndCount)
            successExpectation.fulfill()
        }.catch { _ in
            failureExpectation.fulfill()
        }

        // Waits for the expectations
        waitForExpectations(timeout: 1, handler: nil)
    }
}
