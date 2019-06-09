//
//  DataController.swift
//  CKL iOS Challenge
//
//  Created by Marcelo Salloum dos Santos on 17/01/19.
//  Copyright © 2019 Marcelo Salloum dos Santos. All rights reserved.
//

//import UIKit
import CoreData

struct FatalMeessage {
    static let missingSetupModel = """
    Missing 'EZCoreData' setup. Pleaase use: 'setupPersistence' or 'setupInMemoryPersistence'.
    """

    static let missingMethodOverride = """
    [EZCoreData] FATAL! YOU MUST OVERRIDE METHOD populateFromJSON IN YOUR NSManagedObject subclasses!
    """
}

public class EZCoreData: NSObject {
    // MARK: - SetUp/Init

    /// Shared instance of `EZCoreData`. If the shared version is not enough for your case
    /// you're encoouraged to create an intance of your own
    public static let shared: EZCoreData = EZCoreData()

    /// Persistent container
    fileprivate var _persistentContainer: NSPersistentContainer?

    /// Persistent container
    public var persistentContainer: NSPersistentContainer {
        get {
            if let persistentContainer = _persistentContainer {
                return persistentContainer
            }
            fatalError(FatalMeessage.missingSetupModel)
        }
        set(newValue) {
            _persistentContainer = newValue
        }
    }

    /// Initialization of a persistent NSPersistentContainer
    public func setupPersistence(_ modelName: String, _ completion: (() -> Void)? = nil) {
        if _persistentContainer != nil { return }
        persistentContainer = NSPersistentContainer(name: modelName)
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
            completion?()
        }
    }

    /// Initialization of an in-memory NSPersistentContainer
    public func setupInMemoryPersistence(_ modelName: String, _ completion: (() -> Void)? = nil) {
        if _persistentContainer != nil { return }
        persistentContainer = NSPersistentContainer(name: modelName)

        // NSPersistentStoreDescription
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false // Make it simpler in test env
        persistentContainer.persistentStoreDescriptions = [description]

        persistentContainer.loadPersistentStores { (description, error) in
            // Check if the data store is in memory
            precondition(description.type == NSInMemoryStoreType)

            // Check if creating container has gone wrong
            if let error = error {
                fatalError("Creating an in-mem coordinator failed \(error)")
            }
            completion?()
        }
    }

    // MARK: - NSManagedObjectContext SetUp
    /// Configure NSManagedObjectContext for allowing parent to update directly on child
    func configureContext(_ context: NSManagedObjectContext) {
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    /// NSManagedObjectContext that executes in Main Thread
    public lazy var mainThreadContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        configureContext(managedObjectContext)
        return managedObjectContext

    }()

    /// returns the default NSManagedObjectContext that executes in a Private Thread
    public lazy var privateThreadContext: NSManagedObjectContext = {
        return newPrivateContext(withPatent: self.mainThreadContext)
    }()

    /// Returns a new NSManagedObjectContext that executes in a Private Thread
    public func newPrivateContext(withPatent parent: NSManagedObjectContext = EZCoreData.mainThreadContext) ->
    NSManagedObjectContext {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.parent = parent
        configureContext(managedObjectContext)
        return managedObjectContext
    }

    /// static NSManagedObjectContext that executes in Main Thread
    public static var mainThreadContext: NSManagedObjectContext {
        return shared.mainThreadContext
    }

    /// static NSManagedObjectContext that executes in a Private Thread
    public static var privateThreadContext: NSManagedObjectContext {
        return shared.privateThreadContext
    }
}
