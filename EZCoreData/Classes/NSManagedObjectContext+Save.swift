//
//  NSManagedObjectContext+Save.swift
//  EZCoreData
//
//  Created by Marcelo Salloum dos Santos on 22/01/19.
//
// `NSManagedObjectContext+Save` contains a convenience method (actually, sync and/or async versions of a method) for when you want to ensure the `privateThreadContext` saved changes will be propagated in it's parent and simblings.

import Foundation
import CoreData


public extension NSManagedObjectContext {
    
    /// Saves the context ASYNCRONOUSLY. Also saves context parents recursively (parent, then parent's parent, and so on
    public func saveContextToStore(_ completion: @escaping (EZCoreDataResult<Any>) -> Void) {
        func saveFlow() {
            do {
                try regularSaveFlow()
                if let parentContext = parent {
                    parentContext.saveContextToStore(completion)
                } else {
                    completion(.success(result: nil))
                }
            } catch let error {
                EZCoreDataLogger.log("Unable to Save Changes of Private Managed Object Context", verboseLevel: .error)
                EZCoreDataLogger.log(error.localizedDescription, verboseLevel: .error)
                completion(.failure(error: error))
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
    
    /// Saves the context SYNCRONOUSLY. Also saves context parents recursively (parent, then parent's parent, and so on
    public func saveContextToStore() {
        do {
            try regularSaveFlow()
            if let parentContext = parent {
                return parentContext.saveContextToStore()
            } else {
                return
            }
        } catch let error {
            EZCoreDataLogger.log("Unable to Save Changes of Private Managed Object Context", verboseLevel: .error)
            EZCoreDataLogger.log(error.localizedDescription, verboseLevel: .error)
            return
        }
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
