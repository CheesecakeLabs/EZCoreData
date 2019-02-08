//
//  EZTestCase.swift
//  EZCoreData_Tests
//
//  Created by Marcelo Salloum dos Santos on 05/02/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import CoreData
@testable import EZCoreData
@testable import EZCoreData_Example

// MARK: - Mocking Core Data:
class EZTestCase: XCTestCase {

    override func setUp() {
        EZCoreData.shared.setupInMemoryPersistence("Model")
        eraseAllArticles()
        importAllArticles()
    }

    var context: NSManagedObjectContext {
        return EZCoreData.shared.mainThreadContext
    }

    var backgroundContext: NSManagedObjectContext {
        return EZCoreData.shared.privateThreadContext
    }

    public func eraseAllArticles() {
        try? Article.deleteAll(context: context)
        let countZero = try? Article.count(context: context)
        XCTAssertEqual(countZero, 0)
    }

    public func importAllArticles() {
        _ = try? Article.importList(mockArticleListResponseJSON, idKey: "id", shouldSave: true, context: context)
        let countSix = try? Article.count(context: context)
        XCTAssertEqual(countSix, mockArticleListResponseJSON.count)
    }
}

