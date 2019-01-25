//
//  EZCoreDataLogger.swift
//  EZCoreData
//
//  Created by Marcelo Salloum dos Santos on 22/01/19.
//

import CoreData
import UIKit


// MARK: - Result Handling
/// Handles any kind of results
public enum EZCoreDataResult<Object> {
    /// Handles success results
    case success(result: Object?)
    
    /// Handles failure results
    case failure(error: Error)
}


// MARK: - Error Handling
/// Error Handling for the EZCoreData lib
public enum EZCoreDataError: Error {
    /// Programmer has provided an empty JSON
    case jsonIsEmpty
    
    /// Object returned from `getOrCreate` method is surprisingly empty
    case getOrCreateObjIsEmpty
    
    /// The `idKey` provided is not available in the given NSManagedObject
    case invalidIdKey
}


// MARK: - Logging Handling
/// Printing Level
public enum EZCoreDataLogLevel: Int {
    /// Prints nothing
    case none = 0
    
    /// Prints only errors
    case error = 1
    
    /// Prints only errors and warnings
    case warning = 2
    
    /// Prints everything
    case info = 3
}


public struct EZCoreDataLogger {
    
    fileprivate static let libName = "[EZCoreData]"
    
    /// Authorized Logging level. Can be any of the following: [none, error, warning, info]
    static var authorizedVerbose = EZCoreDataLogLevel.info
    
    /// Prints `logText` if `verboseLevel > authorizedVerbose`
    static func log(_ logText: Any?, verboseLevel: EZCoreDataLogLevel = .info) {
        guard let text = logText else { return }
        if (verboseLevel.rawValue > self.authorizedVerbose.rawValue) { return }
        print("\(libName) \(String(describing: verboseLevel).uppercased()): \(text)")
    }
}
