//
//  NSManagedObject+Delete.swift
//  CKL iOS Challenge
//
//  Created by Marcelo Salloum dos Santos on 10/01/19.
//  Copyright © 2019 Marcelo Salloum dos Santos. All rights reserved.
//

import Foundation
import CoreData
import PromiseKit

// MARK: - Delete One
extension NSFetchRequestResult where Self: NSManagedObject {
    /// Delete given object within the given context
    static public func delete(_ object: Self, context: NSManagedObjectContext) throws {
        context.delete(object)
    }

    /// Delete the object within the given context
    public func delete() {
        self.managedObjectContext?.delete(self)
    }
}

// MARK: Delete List
extension NSFetchRequestResult where Self: NSManagedObject {
    static public func deleteAll(fromList objectList: [Self],
                                 _ backgroundContext: NSManagedObjectContext) -> Promise<Void> {

        return Promise<Void> { resolver in
            backgroundContext.perform {
                let objectCount = objectList.count
                var objectType: String = "Unknown"
                EZCoreDataLogger.log("Attempting to delete a list of \(objectCount) objects of type '\(objectType)'")
                for object in objectList {
                    objectType = String(describing: type(of: object))
                    object.delete()
                }
                resolver.fulfill_()
            }
        }
    }

    /// Delete all objects returned in the given NSFetchRequest
    static public func deleteAll(fromPredicate predicate: NSPredicate?,
                                 backgroundContext: NSManagedObjectContext) -> Promise<Void> {
        return self.readAll(predicate, context: backgroundContext).then { objectList -> Promise<Void> in
            self.deleteAll(fromList: objectList, backgroundContext)
        }
    }

    /// Delete all objects of this kind except the given list
    static public func deleteAll(exceptFromList toKeep: [Self]? = nil,
                                 backgroundContext: NSManagedObjectContext) -> Promise<Void> {
        // Predicate
        var predicate: NSPredicate?
        if let toKeep = toKeep, toKeep.count > 0 {
            predicate = NSPredicate(format: "NOT (self IN %@)", toKeep)
        }
        return deleteAll(fromPredicate: predicate, backgroundContext: backgroundContext)
    }
}
