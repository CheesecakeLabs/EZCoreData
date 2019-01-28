//
//  DataController.swift
//  CKL iOS Challenge
//
//  Created by Marcelo Salloum dos Santos on 17/01/19.
//  Copyright © 2019 Marcelo Salloum dos Santos. All rights reserved.
//

//import UIKit
import CoreData


// MARK: - SetUp/Init
public class EZCoreData: NSObject {
    /// Shared instance of `EZCoreData`. If the shared version is not enough for your case, you're encoouraged to create an intance of your own
    public static let shared: EZCoreData = EZCoreData()
    
    /// Persistent container
    fileprivate var _persistentContainer: NSPersistentContainer?
    
    /// Persistent container
    public var persistentContainer: NSPersistentContainer {
        get {
            if let persistentContainer = _persistentContainer {
                return persistentContainer
            }
            fatalError("You need to initialize the 'EZCoreData' instance using one of the mehods: 'setupPersistence' or 'setupInMemoryPersistence'. A simple way to do so is: 'EZCoreData.shared.setupPersistence(\"Model\")'")
        }
        set(newValue) {
            _persistentContainer = newValue
        }
    }
    
    /// Setup the persistentContainer: NSPersistentContainer so the saved changes will be persisted in the database
    public func setupPersistence(_ modelName: String, _ completion: (() -> Void)? = nil) {
        self.setupPersistentStoreCoordinator(modelName, completion)
    }
    
    /// Setup the persistentContainer: NSPersistentContainer so the saved instances will remain in memory and not be persisted. It's useful for unit tests
    public func setupInMemoryPersistence(_ modelName: String, _ completion: (() -> Void)? = nil) {
        self.setupInMemoryStoreCoordinator(modelName, completion)
    }
    
    /// Async initialization of a persistent NSPersistentContainer
    private func setupPersistentStoreCoordinator(_ modelName: String, _ completion: (() -> Void)? = nil) {
        if _persistentContainer != nil { return }
        persistentContainer = NSPersistentContainer(name: modelName)
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
            completion?()
        }
    }
    
    /// Async initialization of an in-memory NSPersistentContainer
    private func setupInMemoryStoreCoordinator(_ modelName: String, _ completion: (() -> Void)? = nil) {
        if _persistentContainer != nil { return }
        persistentContainer = NSPersistentContainer(name: modelName)
        
        // NSPersistentStoreDescription
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false // Make it simpler in test env
        persistentContainer.persistentStoreDescriptions = [description]
        
        persistentContainer.loadPersistentStores { (description, error) in
            // Check if the data store is in memory
            precondition( description.type == NSInMemoryStoreType )
            
            // Check if creating container has gone wrong
            if let error = error {
                fatalError("Creating an in-mem coordinator failed \(error)")
            }
            completion?()
        }
    }

    // MARK: - NSManagedObjectContext SetUp
    /// NSManagedObjectContext that executes in Main Thread
    public lazy var mainThredContext: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    /// NSManagedObjectContext that executes in a Private Thread
    public lazy var privateThreadContext: NSManagedObjectContext = {
        
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.parent = self.mainThredContext
        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return backgroundContext
    }()
    
    /// static NSManagedObjectContext that executes in Main Thread
    public static var mainThredContext: NSManagedObjectContext {
        return shared.mainThredContext
    }

    /// static NSManagedObjectContext that executes in a Private Thread
    public static var privateThreadContext: NSManagedObjectContext {
        return shared.privateThreadContext
    }
}
