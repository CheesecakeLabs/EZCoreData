//
//  NSManagedObject+Update.swift
//  CKL iOS Challenge
//
//  Created by Marcelo Salloum dos Santos on 10/01/19.
//  Copyright © 2019 Marcelo Salloum dos Santos. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Used for importing a JSON into an NSManagedObjectContext
extension NSManagedObject {
    /// All NSManagedObject children need to override this
    @objc open func populateFromJSON(_ json: [String: Any], context: NSManagedObjectContext) {
        fatalError(FatalMeessage.missingMethodOverride)
    }
}

// MARK: - Get or Create
extension NSFetchRequestResult where Self: NSManagedObject {
    /// GET or CREATE object with `attribute` equals `value`
    public static func getOrCreate(attribute: String, value: String, context: NSManagedObjectContext) -> Self? {
        // Initializing return variables
        var fetchedObjects: [Self] = []

        // GET, if idKey exists
        do {
            fetchedObjects = try readAll(predicate: NSPredicate(format: "\(attribute) == \(value)"), context: context)
        } catch let error {
            EZCoreDataLogger.log(error.localizedDescription, verboseLevel: .error)
            return nil
        }

        // CREATE if idKey doesn't exist
        if fetchedObjects.count > 0 {
            return fetchedObjects[0]
        }
        return Self.init(entity: self.entity(), insertInto: context)
    }
}

// MARK: - Import from JSON
extension NSFetchRequestResult where Self: NSManagedObject {
    /// SYNC Import JSON Dict to Object
    public static func importObject(_ jsonObject: [String: Any]?,
                                    idKey: String? = nil,
                                    shouldSave: Bool,
                                    context: NSManagedObjectContext = EZCoreData.mainThreadContext) throws -> Self {
        guard let jsonObject = jsonObject else { throw EZCoreDataError.jsonIsEmpty }

        // If no idKey is passed, a new object is created
        var object: Self!
        if let idKey = idKey {
            guard let objectId = jsonObject[idKey] as? Int else { throw EZCoreDataError.invalidIdKey }
            guard let newObject = getOrCreate(attribute: idKey,
                                              value: String(describing: objectId),
                                              context: context) else { throw EZCoreDataError.getOrCreateObjIsEmpty }
            object = newObject
        } else {
            object = Self.create(in: context)
        }

        object.populateFromJSON(jsonObject, context: context)
        // Context Save
        if shouldSave {
            context.saveContextToStore()
        }
        return object
    }

    /// SYNC import a JSON array into a list of objects and then save them to CoreData
    public static func importList(_ jsonArray: [[String: Any]]?,
                                  idKey: String? = nil,
                                  shouldSave: Bool,
                                  context: NSManagedObjectContext = EZCoreData.mainThreadContext) throws -> [Self]? {
        // Input validations
        guard let jsonArray = jsonArray else { throw EZCoreDataError.jsonIsEmpty }
        if jsonArray.isEmpty { throw EZCoreDataError.jsonIsEmpty }
        var objectsArray: [Self] = []

        // Looping over the array then GET or CREATE
        for objectJSON in jsonArray {
            let object = try importObject(objectJSON, idKey: idKey, shouldSave: false, context: context)
            objectsArray.append(object)
        }

        // Context Save
        if shouldSave {
            context.saveContextToStore()
        }
        return objectsArray
    }

    /// ASYNC import a JSON array into a list of objects and then save them to CoreData
    public static func importList(_ jsonArray: [[String: Any]]?,
                                  idKey: String? = nil,
                                  backgroundContext: NSManagedObjectContext = EZCoreData.privateThreadContext,
                                  completion: @escaping (EZCoreDataResult<[Self]>) -> Void) {
        backgroundContext.perform {
            // Input validations
            guard let jsonArray = jsonArray, jsonArray.count > 0, !jsonArray.isEmpty else {
                completion(EZCoreDataResult<[Self]>.failure(error: EZCoreDataError.jsonIsEmpty))
                return
            }
            var objectsArray: [Self] = []

            // Looping over the array then GET or CREATE
            for objectJSON in jsonArray {
                do {
                    let object = try importObject(objectJSON,
                                                  idKey: idKey,
                                                  shouldSave: false,
                                                  context: backgroundContext)
                    objectsArray.append(object)
                } catch let error {
                    completion(EZCoreDataResult<[Self]>.failure(error: error))
                    return
                }
            }

            // Context Save
            backgroundContext.saveContextToStore({ (result) in
                switch result {
                case .success(result: _):
                    completion(EZCoreDataResult<[Self]>.success(result: objectsArray))
                case .failure(error: let error):
                    completion(EZCoreDataResult<[Self]>.failure(error: error))
                }
            })
        }
    }
}
