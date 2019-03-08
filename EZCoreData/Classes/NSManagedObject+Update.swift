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
    /// GET or CREATE object with `attribute` equals `value`, where value is a String
    public static func getOrCreate(attribute: String, value: String, context: NSManagedObjectContext) -> Self? {
        let predicate = comparisionPredicate(attribute: attribute, value: value)
        return getOrCreate(predicate: predicate, attribute: attribute, value: value, context: context)
    }

    /// GET or CREATE object with `attribute` equals `value`, where value is an Int
    public static func getOrCreate(attribute: String, value: Int, context: NSManagedObjectContext) -> Self? {
        let predicate = comparisionPredicate(attribute: attribute, value: value)
        return getOrCreate(predicate: predicate, attribute: attribute, value: value, context: context)
    }

    /// GET or CREATE object with a given predicate
    private static func getOrCreate(predicate: NSPredicate, attribute: String,
                                    value: Any?, context: NSManagedObjectContext) -> Self? {
        // Initializing return variables
        var fetchedObjects: [Self] = []

        // GET, if idKey exists
        do {
            fetchedObjects = try readAll(predicate: predicate, context: context)
            if fetchedObjects.count > 0 {
                return fetchedObjects[0]
            }
        } catch let error {
            EZCoreDataLogger.log(error.localizedDescription, verboseLevel: .error)
            return nil
        }

        // CREATE if idKey doesn't exist
        let newObject = Self.init(entity: self.entity(), insertInto: context)
        newObject.setValue(value, forKey: attribute)
        return newObject
    }

    /// Creates a comparision predicate where the keyPath value is an Int
    static public func comparisionPredicate(attribute: String, value: Int) -> NSPredicate {
        return NSPredicate(format: "\(attribute) == \(value)")
    }

    /// Creates a comparision predicate where the keyPath value is a String
    static public func comparisionPredicate(attribute: String, value: String) -> NSPredicate {
        return NSPredicate(format: "\(attribute) == %@", value)
    }
}

// MARK: - Import from JSON
extension NSFetchRequestResult where Self: NSManagedObject {
    /// SYNC Import JSON Dict to Object
    public static func importObject(_ jsonObject: [String: Any]?,
                                    idKey: String? = nil,
                                    context: NSManagedObjectContext = EZCoreData.mainThreadContext) throws -> Self {
        guard let jsonObject = jsonObject else { throw EZCoreDataError.jsonIsEmpty }

        // If no idKey is passed, a new object is created
        var object: Self!
        if let idKey = idKey {
            if let objectId = jsonObject[idKey] as? Int {
                if let newObject = getOrCreate(attribute: idKey, value: objectId, context: context) {
                    object = newObject
                } else {
                    throw EZCoreDataError.getOrCreateObjIsEmpty
                }
            } else if let objectId = jsonObject[idKey] as? String {
                if let newObject = getOrCreate(attribute: idKey, value: objectId, context: context) {
                    object = newObject
                } else {
                    throw EZCoreDataError.getOrCreateObjIsEmpty
                }
            } else {
                throw EZCoreDataError.invalidIdKey
            }
        } else {
            object = Self.create(in: context)
        }

        object.populateFromJSON(jsonObject, context: context)
        return object
    }

    /// SYNC import a JSON array into a list of objects and then save them to CoreData
    public static func importList(_ jsonArray: [[String: Any]]?,
                                  idKey: String? = nil,
                                  context: NSManagedObjectContext = EZCoreData.mainThreadContext) throws -> [Self]? {
        // Input validations
        guard let jsonArray = jsonArray else { throw EZCoreDataError.jsonIsEmpty }
        if jsonArray.isEmpty { throw EZCoreDataError.jsonIsEmpty }
        var objectsArray: [Self] = []

        // Looping over the array then GET or CREATE
        for objectJSON in jsonArray {
            let object = try importObject(objectJSON, idKey: idKey, context: context)
            objectsArray.append(object)
        }

        // Context Save
        return objectsArray
    }

    /// ASYNC import a JSON array into a list of objects and then save them to CoreData
    public static func importList(_ jsonArray: [[String: Any]]?,
                                  idKey: String? = nil,
                                  backgroundContext: NSManagedObjectContext = EZCoreData.privateThreadContext,
                                  completion: @escaping (EZCoreDataResult<[Self]>) -> Void) {
        backgroundContext.perform {
            do {
                let objectsArray = try self.importList(jsonArray, idKey: idKey, context: backgroundContext)
                completion(EZCoreDataResult<[Self]>.success(result: objectsArray))
            } catch let error {
                completion(EZCoreDataResult<[Self]>.failure(error: error))
            }
        }
    }
}
