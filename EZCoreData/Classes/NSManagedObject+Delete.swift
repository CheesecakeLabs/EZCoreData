//
//  NSManagedObject+Delete.swift
//  CKL iOS Challenge
//
//  Created by Marcelo Salloum dos Santos on 10/01/19.
//  Copyright © 2019 Marcelo Salloum dos Santos. All rights reserved.
//

import CoreData
import Promise


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
    
    /// ASYNC Delete all objects of this kind except the given list
    static public func deleteAll(except toKeep: [Self]? = nil,
                                 backgroundContext: NSManagedObjectContext = EZCoreData.privateThreadContext) -> Promise<Any?> {
        let promise = Promise<Any?> { (fulfill, reject) in
            backgroundContext.perform {
                // Predicate
                var predicate: NSPredicate?
                if let toKeep = toKeep, toKeep.count > 0 {
                    predicate = NSPredicate(format: "NOT (self IN %@)", toKeep)
                }
                
                deleteAllFromFetchRequest(predicate, context: backgroundContext).then(fulfill).catch(reject)
            }
        }
        
        return promise.then({ _ in
            // Saves the deletion to the store before returning
            backgroundContext.saveContextToStore()
        })
    }
}


// MARK: - Delete All By Attribute
extension NSFetchRequestResult where Self: NSManagedObject {
    
    /// ASYNC Delete all objects of this kind except those with the given attribute
    static public func deleteAllByAttribute(except attributeName: String,
                                            toKeep: [String],
                                            backgroundContext: NSManagedObjectContext = EZCoreData.privateThreadContext) -> Promise<Any?> {
        let promise = Promise<Any?> { (fulfill, reject) in
            
            backgroundContext.perform {
                // Delete Request
                let predicate = NSPredicate(format: "NOT (\(attributeName) IN %@)", toKeep)
                deleteAllFromFetchRequest(predicate, context: backgroundContext).then(fulfill).catch(reject)
            }
        }
        
        return promise.then({ _ in
            // Saves the deletion to the store before returning
            backgroundContext.saveContextToStore()
        })
    }
}


// MARK: - Private Funcs
extension NSFetchRequestResult where Self: NSManagedObject {
    /// Delete all objects returned in the given NSFetchRequest
    fileprivate static func deleteAllFromFetchRequest(_ predicate: NSPredicate?,
                                                       context: NSManagedObjectContext) -> Promise<Any?> {
        let promise = Promise<Any?> { (fulfill, reject) in
        
            self.readAll(predicate: predicate, context: context).then({ (objectList) in
                let objectCount = objectList.count
                var objectType: String = "Unknown"
                for object in objectList {
                    objectType = String(describing: type(of: object))
                    try object.delete(shouldSave: false, context: context)
                }
                if (objectCount > 0) {
                    EZCoreDataLogger.log("Attempting to delete a list of \(objectCount) objects of type '\(objectType)'")
                } else {
                    EZCoreDataLogger.log("No objects to be deleted")
                }
                fulfill(nil)
            })
        }
        
        return promise
    }
}
