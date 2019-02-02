//
//  NSManagedObject+Read.swift
//  CKL iOS Challenge
//
//  Created by Marcelo Salloum dos Santos on 10/01/19.
//  Copyright © 2019 Marcelo Salloum dos Santos. All rights reserved.
//

import CoreData
import Promise



// MARK: - Create Helpers
extension NSFetchRequestResult where Self: NSManagedObject {
    
    static public func create(in context: NSManagedObjectContext = EZCoreData.mainThreadContext, shouldSave: Bool = false) -> Promise<Self> {
        let promise = Promise<Self> { (fulfill, reject) in
            let newObject = self.init(entity: self.entity(), insertInto: context)
            // Context Save
            if (shouldSave) {
                context.saveContextToStore().then({ _ in
                    fulfill(newObject)
                }).catch(reject)
            } else {
                fulfill(newObject)
            }
        }
        return promise
    }
}
