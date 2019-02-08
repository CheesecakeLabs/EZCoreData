//
//  TestEZCoreData.swift
//  EZCoreData_Tests
//
//  Created by Marcelo Salloum dos Santos on 08/02/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import EZCoreData_Example
@testable import EZCoreData

class TestEZCoreData: EZTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testErrorWhenNotCallingSetupPersistence() {
        let ezCoreData = EZCoreData()
        ezCoreData.setupPersistence("Model")
        XCTAssertNotNil(ezCoreData.persistentContainer)
    }

}
