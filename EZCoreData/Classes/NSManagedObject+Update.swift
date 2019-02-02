//
//  NSManagedObject+Update.swift
//  CKL iOS Challenge
//
//  Created by Marcelo Salloum dos Santos on 10/01/19.
//  Copyright © 2019 Marcelo Salloum dos Santos. All rights reserved.
//

import CoreData
import Promise


// MARK: - Used for importing a JSON into an NSManagedObjectContext
extension NSManagedObject {
    /// All NSManagedObject children need to override this
    @objc open func populateFromJSON(_ json: [String: Any], context: NSManagedObjectContext) {
        fatalError("\n\n [EZCoreData] FATAL ERROR!!!  ATTENTION, YOU MUST OVERRIDE METHOD populateFromJSON(_ json: [String: Any], context: NSManagedObjectContext) IN YOUR NSManagedObject subclasses!!! \n\n")
    }
}


// MARK: - Get or Create
extension NSFetchRequestResult where Self: NSManagedObject {
    /// GET or CREATE object with `attribute` equals `value`
    public static func getOrCreate(attribute: String, value: String, context: NSManagedObjectContext) -> Promise<Self> {

        let promise = Promise<Self> { (fulfill, reject) in
            let predicate = NSPredicate(format: "\(attribute) == \(value)")
            readFirst(predicate, context: context).then({ (fetchedObjects) in
                // CREATE if idKey doesn't exist
                if (fetchedObjects.count > 0) {
                    fulfill(fetchedObjects[0])
                } else {
                    fulfill(self.init(entity: self.entity(), insertInto: context))
                }
            }) { (error) in
                EZCoreDataLogger.log(error.localizedDescription, verboseLevel: .error)
            }
        }
        return promise
    }
}


// MARK: - Import from JSON
extension NSFetchRequestResult where Self: NSManagedObject {
    /// SYNC Import JSON Dict to Object
    public static func importObject(_ jsonObject: [String: Any]?,
                                    idKey: String = "id",
                                    shouldSave: Bool,
                                    context: NSManagedObjectContext = EZCoreData.mainThreadContext) -> Promise<Self> {
        
        let promise = Promise<Self> { (fulfill, reject) in
            guard let jsonObject = jsonObject else { throw EZCoreDataError.jsonIsEmpty }
            guard let objectId = jsonObject[idKey] as? Int else { throw EZCoreDataError.invalidIdKey }
            
            getOrCreate(attribute: idKey, value: String(describing: objectId), context: context).then({ (object) in
                object.populateFromJSON(jsonObject, context: context)
                // Context Save
                if (shouldSave) {
                    context.saveContextToStore().then({ _ in
                        fulfill(object)
                    }).catch(reject)
                } else {
                    fulfill(object)
                }
            })
            
        }
        return promise
        
    }
    
    /// ASYNC import a JSON array into a list of objects and then save them to CoreData
    public static func importList(_ jsonArray: [[String: Any]],
                                  idKey: String = "id",
                                  shouldSave: Bool,
                                  context: NSManagedObjectContext = EZCoreData.mainThreadContext) -> Promise<[Self]>  {
        // Looping over the array then GET or CREATE
        let objectsPromises = jsonArray.map({ objectJSON in
            importObject(objectJSON, idKey: idKey, shouldSave: false, context: context)
        })
        
        let promise = Promise<[Self]> { (fulfill, reject) in
            Promises.all(objectsPromises).then({ (objectsArray) in
                // Context Save
                if (shouldSave) {
                    context.saveContextToStore().then({ _ in
                        fulfill(objectsArray)
                    }).catch(reject)
                } else {
                    fulfill(objectsArray)
                }
            })
        }
        
        return promise
    }
}
