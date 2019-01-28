//
//  NSManagedObject+Delete.swift
//  CKL iOS Challenge
//
//  Created by Marcelo Salloum dos Santos on 10/01/19.
//  Copyright © 2019 Marcelo Salloum dos Santos. All rights reserved.
//

import Foundation
import CoreData


// MARK: - Delete One
extension NSFetchRequestResult where Self: NSManagedObject {
    /// Delete given object within the given context
    static public func delete(_ object: Self, shouldSave: Bool = true, context: NSManagedObjectContext = EZCoreData.mainThreadContext) throws {
        context.delete(object)
        if (shouldSave) {
            try context.save()
        }
    }
    
    /// Delete the object within the given context
    public func delete(shouldSave: Bool = true, context: NSManagedObjectContext = EZCoreData.mainThreadContext) throws {
        try Self.delete(self, shouldSave: shouldSave, context: context)
    }
}


// MARK: - Delete All
extension NSFetchRequestResult where Self: NSManagedObject {
    
    /// SYNC Delete all objects of this kind except the given list
    static public func deleteAll(except toKeep: [Self]? = nil,
                                 context: NSManagedObjectContext = EZCoreData.mainThreadContext) throws {
        // Predicate
        var predicate: NSPredicate?
        if let toKeep = toKeep, toKeep.count > 0 {
            predicate = NSPredicate(format: "NOT (self IN %@)", toKeep)
        }
        // Delete Request
        try deleteAllFromFetchRequest(predicate, context: context)
        context.saveContextToStore()
    }
    
    /// ASYNC Delete all objects of this kind except the given list
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
                backgroundContext.saveContextToStore({ (result) in
                    switch result {
                    case .success(result: _):
                        completion(EZCoreDataResult<[Self]>.success(result: nil))
                    case .failure(error: let error):
                        completion(EZCoreDataResult<[Self]>.failure(error: error))
                    }
                })
            } catch let error {
                print(error.localizedDescription)
                print(error)
                completion(.failure(error: error))
            }
        }
    }
}


// MARK: - Delete All By Attribute
extension NSFetchRequestResult where Self: NSManagedObject {
    
    /// SYNC Delete all objects of this kind except those with the given attribute
    static public func deleteAllByAttribute(except attributeName: String,
                                            toKeep: [String],
                                            context: NSManagedObjectContext = EZCoreData.mainThreadContext) throws {
        try deleteAllFromFetchRequest(NSPredicate(format: "NOT (\(attributeName) IN %@)", toKeep), context: context)
    }
    
    /// ASYNC Delete all objects of this kind except those with the given attribute
    static public func deleteAllByAttribute(except attributeName: String,
                                            toKeep: [String],
                                            backgroundContext: NSManagedObjectContext = EZCoreData.privateThreadContext,
                                            completion: @escaping (EZCoreDataResult<[Self]>) -> Void) {
        backgroundContext.perform {
            // Delete Request
            do {
                try deleteAllFromFetchRequest(NSPredicate(format: "NOT (\(attributeName) IN %@)", toKeep), context: backgroundContext)
                completion(.success(result: nil))
            } catch let error {
                EZCoreDataLogger.log(error.localizedDescription, verboseLevel: .error)
                completion(.failure(error: error))
            }
        }
    }
}


// MARK: - Private Funcs
extension NSFetchRequestResult where Self: NSManagedObject {
    /// Delete all objects returned in the given NSFetchRequest
    fileprivate static func deleteAllFromFetchRequest(_ predicate: NSPredicate?,
                                                       context: NSManagedObjectContext) throws {
        let objectList = try self.readAll(predicate: predicate, context: context)
        let objectCount = objectList.count
        var objectType: String = "Unknown"
        for object in objectList {
            objectType = String(describing: type(of: object))
            try object.delete(shouldSave: false, context: context)
        }
        print("Attempting to delete a list of \(objectCount) objects of type '\(objectType)'")
    }
}
