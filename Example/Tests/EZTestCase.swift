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

// MARK: - Mocking Core Data:
class EZTestCase: XCTestCase {

    override func setUp() {
        EZCoreData.shared.setupInMemoryPersistence("Model")
    }

    var context: NSManagedObjectContext {
        return EZCoreData.shared.mainThreadContext
    }

    var backgroundContext: NSManagedObjectContext {
        return EZCoreData.shared.privateThreadContext
    }
}
