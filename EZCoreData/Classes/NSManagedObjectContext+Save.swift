//
//  NSManagedObjectContext+Save.swift
//  EZCoreData
//
//  Created by Marcelo Salloum dos Santos on 22/01/19.
//
// `NSManagedObjectContext+Save` contains a convenience method (actually, sync and/or async versions of a method) for when you want to ensure the `privateThreadContext` saved changes will be propagated in it's parent and simblings.

import CoreData
import Promise


public extension NSManagedObjectContext {
    
    /// Saves the context ASYNCRONOUSLY. Also saves context parents recursively (parent, then parent's parent, and so on
    public func saveContextToStore() -> Promise<Any?> {
        let promise = Promise<Any?>(work: { fulfill, reject in
            self.asyncSaveContextToStore(fulfill, reject)
        })
        return promise
    }
    
    private func asyncSaveContextToStore(_ fulfill: @escaping (Any?) -> (), _ reject: @escaping (Error) -> ()) {
        func saveFlow() {
            do {
                try aregularSaveFlow()
                if let parentContext = parent {
                    parentContext.asyncSaveContextToStore(fulfill, reject)
                } else {
                    fulfill(nil)
                }
            } catch let error {
                print("Unable to Save Changes of Private Managed Object Context")
                print(error.localizedDescription)
                reject(error)
            }
        }
        
        switch concurrencyType {
        case .confinementConcurrencyType:
            saveFlow()
        case .privateQueueConcurrencyType,
             .mainQueueConcurrencyType:
            perform(saveFlow)
        }
    }
    
    /// Saves the context if there is any changes
    private func aregularSaveFlow() throws {
        if !hasChanges {
            print("Context has no changes to be saved")
            return
        }
        try save()
        print("Context successfully saved")
    }
    
    /// Saves the context if there is any changes
    private func regularSaveFlow() throws {
        if !hasChanges {
            EZCoreDataLogger.log("Context has no changes to be saved")
            return
        }
        try save()
        EZCoreDataLogger.log("Context successfully saved")
    }
    
}
