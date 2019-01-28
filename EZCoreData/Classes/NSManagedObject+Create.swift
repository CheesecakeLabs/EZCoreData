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
    
    static public func create(in context: NSManagedObjectContext = EZCoreData.mainThreadContext, shouldSave: Bool = false) -> Self? {
        let newObject = Self.init(entity: self.entity(), insertInto: context)
        if (shouldSave) {
            context.saveContextToStore()
        }
        return newObject
    }
}
