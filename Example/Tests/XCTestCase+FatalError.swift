//
//  XCTestCase+FatalError.swift
//  EZCoreData_Tests
//
//  Created by Marcelo Salloum dos Santos on 14/02/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import EZCoreData

extension XCTestCase {

    func expectFatalError(expectedMessage: String, testcase: @escaping () -> Void) {
        let expectation = self.expectation(description: "expectingFatalError")
        var assertionMessage: String?

        FatalErrorUtil.replaceFatalError { message, _, _ in
            assertionMessage = message
            expectation.fulfill()
            self.unreachable()
        }

        DispatchQueue.global(qos: .userInitiated).async(execute: testcase)

        waitForExpectations(timeout: 0.5) { _ in
            XCTAssertEqual(assertionMessage, expectedMessage)

            FatalErrorUtil.restoreFatalError()
        }
    }

    private func unreachable() -> Never {
        repeat {
            RunLoop.current.run()
        } while (true)
    }

}
