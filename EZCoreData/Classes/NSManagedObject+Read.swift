//
//  NSManagedObject+Read.swift
//  CKL iOS Challenge
//
//  Created by Marcelo Salloum dos Santos on 10/01/19.
//  Copyright © 2019 Marcelo Salloum dos Santos. All rights reserved.
//

import Foundation
import CoreData
import PromiseKit

// MARK: - Read Helpers
extension NSFetchRequestResult where Self: NSManagedObject {

    /// SYNC Fetch Request for reading
    fileprivate static func syncFetchRequest(_ context: NSManagedObjectContext) -> NSFetchRequest<Self> {
        return NSFetchRequest<Self>.init(entityName: String(describing: self))
    }
}

// MARK: - Read First (By Predicate or Attribute)
extension NSFetchRequestResult where Self: NSManagedObject {

    /// SYNC read first result with the given predicate
    static public func readFirst(_ predicate: NSPredicate? = nil, context: NSManagedObjectContext) -> Promise<Self?> {
        return Promise<Self?> { resolver in
            let fetchRequest = syncFetchRequest(context)
            fetchRequest.predicate = predicate
            fetchRequest.fetchLimit = 1
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.fetchBatchSize = 1
            let result = try context.fetch(fetchRequest).first
            resolver.fulfill(result)
        }
    }

    /// SYNC read first result with the given `attribute` and `value`
    static public func readFirst(attribute: String, value: String, context: NSManagedObjectContext) -> Promise<Self?> {
        let predicate = NSPredicate(format: "\(attribute) == \(value)")
        return readFirst(predicate, context: context)
    }
}

// MARK: - Read All (By Predicate or Attribute)
extension NSFetchRequestResult where Self: NSManagedObject {

    /// SYNC read all results with the given predicate
    static public func readAll(_ predicate: NSPredicate? = nil,
                               sortDescriptors: [NSSortDescriptor]? = nil,
                               context: NSManagedObjectContext) -> Promise<[Self]> {
        return Promise<[Self]> { resolver in
            // Prepare the request
            let fetchRequest = syncFetchRequest(context)
            fetchRequest.sortDescriptors = sortDescriptors
            fetchRequest.predicate = predicate
            let result = try context.fetch(fetchRequest)
            resolver.fulfill(result)
        }
    }

    /// SYNC read all results with the given `attribute` and `value`
    static public func readAllByAttribute(_ attribute: String,
                                          value: String,
                                          sortDescriptors: [NSSortDescriptor]? = nil,
                                          context: NSManagedObjectContext) -> Promise<[Self]> {
        // Prepare the request
        let predicate = NSPredicate(format: "\(attribute) CONTAINS[c] '\(value)'")
        return readAll(predicate, sortDescriptors: sortDescriptors, context: context)
    }
}

// MARK: - Count
extension NSFetchRequestResult where Self: NSManagedObject {

    /// SYNC count all objects of this class storedin Core Data
    static public func count(_ predicate: NSPredicate? = nil, context: NSManagedObjectContext) -> Promise<Int> {
        return Promise<Int> { resolver in
            // Prepare the request
            let fetchRequest = syncFetchRequest(context)
            fetchRequest.includesSubentities = false
            fetchRequest.predicate = predicate
            let result = try context.count(for: fetchRequest)
            resolver.fulfill(result)
        }
    }
}
