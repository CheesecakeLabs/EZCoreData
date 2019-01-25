//
//  NSManagedObject+Read.swift
//  CKL iOS Challenge
//
//  Created by Marcelo Salloum dos Santos on 10/01/19.
//  Copyright © 2019 Marcelo Salloum dos Santos. All rights reserved.
//

import Foundation
import CoreData



// MARK: - Create Helpers
extension NSFetchRequestResult where Self: NSManagedObject {
    
    static public func create(in context: NSManagedObjectContext = EZCoreData.mainThredContext, shouldSave: Bool = false) -> Self? {
        let newObject = Self.init(entity: self.entity(), insertInto: context)
        if (shouldSave) {
            context.saveContextToStore()
        }
        return newObject
    }
    
    public func save(in context: NSManagedObjectContext? = nil) {
        let saveContext: NSManagedObjectContext? = (context != nil) ? context : self.managedObjectContext
        if (saveContext == nil) {
            EZCoreDataLogger.log("Attempting to save a NSMangedObject '\(String(describing: type(of: self)))', but it is lacking any NSManagedObjectContext !!!", verboseLevel: .error)
            return
        }
        saveContext?.saveContextToStore()
    }
}
