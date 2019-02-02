//
//  NSManagedObject+Read.swift
//  CKL iOS Challenge
//
//  Created by Marcelo Salloum dos Santos on 10/01/19.
//  Copyright © 2019 Marcelo Salloum dos Santos. All rights reserved.
//

import CoreData
import Promise



// MARK: - Read Helpers
extension NSFetchRequestResult where Self: NSManagedObject {
    
    /// SYNC Fetch Request for reading
    fileprivate static func syncFetchRequest(_ context: NSManagedObjectContext) -> NSFetchRequest<Self> {
        let fetchRequest = self.fetchRequest() as! NSFetchRequest<Self>
        return fetchRequest
    }
    
    /// ASYNC Fetch Request for reading
    static public func asyncFetchRequest(_ fetchRequest: NSFetchRequest<Self>,
                                         context: NSManagedObjectContext) -> Promise<[Self]> {
        
        let promise = Promise<[Self]> { (fulfill, reject) in
            let asynchronousFetchRequest = NSAsynchronousFetchRequest<Self>(fetchRequest: fetchRequest) { (asyncFetchResult) in
                if let fetchedObjects = asyncFetchResult.finalResult {
                    fulfill(fetchedObjects)
                }
            }
            
            do {
                _ = try context.execute(asynchronousFetchRequest)
            } catch {
                EZCoreDataLogger.log(error.localizedDescription, verboseLevel: .error)
                reject(error)
            }
        }
        
        return promise
    }
}


// MARK: - Read First
extension NSFetchRequestResult where Self: NSManagedObject {
    
    /// Fetch Request for reading the first result with the given predicate
    fileprivate static func readFirstFetchRequest(_ predicate: NSPredicate? = nil,
                                      context: NSManagedObjectContext) -> NSFetchRequest<Self> {
        let fetchRequest = syncFetchRequest(context)
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.fetchBatchSize = 1
        return fetchRequest
    }
    
    /// ASYNC read first result with the given predicate
    static public func readFirst(_ predicate: NSPredicate? = nil,
                                 context: NSManagedObjectContext = EZCoreData.mainThreadContext) -> Promise<[Self]> {
        let fetchRequest = readFirstFetchRequest(predicate, context: context)
        return asyncFetchRequest(fetchRequest, context: context)
    }
}


// MARK: - Read First By Attributte
extension NSFetchRequestResult where Self: NSManagedObject {
    
    /// ASYNC read first result with the given `attribute` and `value`
    static public func readFirst(attribute: String,
                                 value: String,
                                 context: NSManagedObjectContext = EZCoreData.mainThreadContext) -> Promise<[Self]> {
        let predicate = NSPredicate(format: "\(attribute) == \(value)")
        let fetchRequest = readFirstFetchRequest(predicate, context: context)
        return asyncFetchRequest(fetchRequest, context: context)
    }
}


// MARK: - Read All
extension NSFetchRequestResult where Self: NSManagedObject {
    
    /// Fetch Request for reading all results with the given predicate
    fileprivate static func readAllFetchRequest(_ predicate: NSPredicate? = nil,
                                                context: NSManagedObjectContext,
                                                sortDescriptors: [NSSortDescriptor]? = nil) -> NSFetchRequest<Self> {
        // Prepare the request
        let fetchRequest = syncFetchRequest(context)
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        return fetchRequest
    }
    
    /// ASYNC read all results with the given predicate
    static public func readAll(predicate: NSPredicate? = nil,
                               sortDescriptors: [NSSortDescriptor]? = nil,
                               context: NSManagedObjectContext = EZCoreData.mainThreadContext) -> Promise<[Self]> {
        // Prepare the request
        let fetchRequest = readAllFetchRequest(predicate, context: context, sortDescriptors: sortDescriptors)
        return asyncFetchRequest(fetchRequest, context: context)
    }
}


// MARK: - Read With Attributes
extension NSFetchRequestResult where Self: NSManagedObject {
    /// Fetch Request for reading all results with the given `attribute` and `value`
    fileprivate static func readAllByAttributeFetchRequest(_ attribute: String? = nil,
                                                           value: String? = nil,
                                                           sortDescriptors: [NSSortDescriptor]? = nil,
                                                           context: NSManagedObjectContext) -> NSFetchRequest<Self> {
        // Prepare the request
        let fetchRequest = readAllFetchRequest(context: context, sortDescriptors: sortDescriptors)
        guard let attribute = attribute, let value = value  else { return fetchRequest }
        fetchRequest.predicate = NSPredicate(format: "\(attribute) CONTAINS[c] '\(value)'")
        return fetchRequest

    }
    
    /// ASYNC read all results with the given `attribute` and `value`
    static public func readAllByAttribute(_ attribute: String? = nil,
                                          value: String? = nil,
                                          sortDescriptors: [NSSortDescriptor]? = nil,
                                          context: NSManagedObjectContext = EZCoreData.mainThreadContext) -> Promise<[Self]> {
        // Prepare the request
        let fetchRequest = readAllByAttributeFetchRequest(attribute, value: value, sortDescriptors: sortDescriptors, context: context)
        return asyncFetchRequest(fetchRequest, context: context)
    }
}


// MARK: - Count
extension NSFetchRequestResult where Self: NSManagedObject {

    /// SYNC count all objects of this class storedin Core Data
    static public func count(predicate: NSPredicate? = nil,
                             context: NSManagedObjectContext = EZCoreData.mainThreadContext) throws -> Int {
        // Prepare the request
        let fetchRequest = syncFetchRequest(context)
        fetchRequest.includesSubentities = false
        fetchRequest.predicate = predicate
        return try context.count(for: fetchRequest)
    }
}
