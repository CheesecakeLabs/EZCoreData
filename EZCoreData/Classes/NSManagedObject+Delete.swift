//
//  NSManagedObject+Delete.swift
//  CKL iOS Challenge
//
//  Created by Marcelo Salloum dos Santos on 10/01/19.
//  Copyright © 2019 Marcelo Salloum dos Santos. All rights reserved.
//

import Foundation
import CoreData

// MARK: Basic Functions
extension NSFetchRequestResult where Self: NSManagedObject {
    static public func deleteObjects(fromList objectList: [Self],
                                     _ context: NSManagedObjectContext = EZCoreData.mainThreadContext) throws {
        let objectCount = objectList.count
        var objectType: String = "Unknown"
        for object in objectList {
            objectType = String(describing: type(of: object))
            try object.delete(context: context)
        }
        EZCoreDataLogger.log("Attempting to delete a list of \(objectCount) objects of type '\(objectType)'")
    }

    static public func deleteObjects(fromList objectList: [Self],
                                     _ backgroundContext: NSManagedObjectContext = EZCoreData.privateThreadContext,
                                     completion: @escaping (EZCoreDataResult<[Self]>) -> Void) {
        backgroundContext.perform {
            do {
                try deleteObjects(fromList: objectList, backgroundContext)
                completion(EZCoreDataResult<[Self]>.success(result: nil))
            } catch let error {
                EZCoreDataLogger.log(error.localizedDescription, verboseLevel: .error)
                completion(.failure(error: error))
            }
        }
    }
}

// MARK: - Delete One
extension NSFetchRequestResult where Self: NSManagedObject {
    /// Delete given object within the given context. You must manualy save afterwards
    static public func delete(_ object: Self,
                              context: NSManagedObjectContext = EZCoreData.mainThreadContext) throws {
        context.delete(object)
    }

    /// Delete the object within the given context. You must manualy save afterwards
    public func delete(context: NSManagedObjectContext = EZCoreData.mainThreadContext) throws {
        try Self.delete(self, context: context)
    }
}

// MARK: - Delete All
extension NSFetchRequestResult where Self: NSManagedObject {

    /// SYNC Delete all objects of this kind except the given list. You must manualy save afterwards
    static public func deleteAll(except toKeep: [Self]? = nil,
                                 context: NSManagedObjectContext = EZCoreData.mainThreadContext) throws {
        // Predicate
        var predicate: NSPredicate?
        if let toKeep = toKeep, toKeep.count > 0 {
            predicate = NSPredicate(format: "NOT (self IN %@)", toKeep)
        }
        // Delete Request
        try deleteAllFromFetchRequest(predicate, context: context)
    }

    /// ASYNC Delete all objects of this kind except the given list. You must manualy save afterwards
    static public func deleteAll(except toKeep: [Self]? = nil,
                                 backgroundContext: NSManagedObjectContext = EZCoreData.privateThreadContext,
                                 completion: @escaping (EZCoreDataResult<[Self]>) -> Void) {
        backgroundContext.perform {
            // Predicate
            var predicate: NSPredicate?
            if let toKeep = toKeep, toKeep.count > 0 {
                predicate = NSPredicate(format: "NOT (self IN %@)", toKeep)
            }
            do {
                // Delete Request
                try deleteAllFromFetchRequest(predicate, context: backgroundContext)
                completion(EZCoreDataResult<[Self]>.success(result: nil))
            } catch let error {
                EZCoreDataLogger.log(error.localizedDescription, verboseLevel: .error)
                completion(.failure(error: error))
            }
        }
    }
}

// MARK: - Private Funcs
extension NSFetchRequestResult where Self: NSManagedObject {

    /// Delete all objects returned in the given NSFetchRequest. You must manualy save afterwards
    fileprivate static func deleteAllFromFetchRequest(_ predicate: NSPredicate?,
                                                      context: NSManagedObjectContext) throws {
        let objectList = try self.readAll(predicate: predicate, context: context)
        try deleteObjects(fromList: objectList, context)
    }
}
