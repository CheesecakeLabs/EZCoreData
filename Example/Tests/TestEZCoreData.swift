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
        // Please leave it here. I don'y need the default instance of EZCoreData for the tests below
    }

    func testNoErrorWhenCallingSetupPersistence() {
        let ezCoreData = EZCoreData()
        ezCoreData.setupPersistence("Model")
        XCTAssertNotNil(ezCoreData.persistentContainer)
    }

    func testFatalErrorIfSetupWasntDone() {
        let ezCoreData = EZCoreData()
        expectFatalError(expectedMessage: FatalMeessage.missingSetupModel) {
            ezCoreData.persistentContainer.newBackgroundContext()
        }
    }

    func testFatalErrorIfModelNameWasWrong() {
        let myEZCoreData = EZCoreData()
        self.expectFatalError(expectedMessage: FatalMeessage.missingSetupModel) {
            myEZCoreData.setupInMemoryPersistence("aaa")
        }
    }
}
