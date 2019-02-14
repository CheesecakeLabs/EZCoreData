//
//  FatalErrorUtil.swift
//  EZCoreData
//
//  Created by Marcelo Salloum dos Santos on 14/02/19.
//  This is a test utility used to allow teesting the fatalError appearances in the code

import Foundation

public func fatalError(_ message: @autoclosure () -> String = "",
                       file: StaticString = #file,
                       line: UInt = #line) -> Never {
    FatalErrorUtil.fatalErrorClosure(message(), file, line)
}

struct FatalErrorUtil {
    // 1 - Closure which provides the implementation of fatalError. By default, it uses the one provided by Swift.
    static var fatalErrorClosure: (String, StaticString, UInt) -> Never = defaultFatalErrorClosure
    // 2 - Default fatalError implementation provided by Swift.
    private static let defaultFatalErrorClosure = { Swift.fatalError($0, file: $1, line: $2) }
    // 3 - Static method to replace the fatalError implementation with a custom one.
    static func replaceFatalError(closure: @escaping (String, StaticString, UInt) -> Never) {
        fatalErrorClosure = closure
    }
    // 4 - Restores the fatalError implementation with the default one. We'll need it later for the unit tests.
    static func restoreFatalError() {
        fatalErrorClosure = defaultFatalErrorClosure
    }
}
