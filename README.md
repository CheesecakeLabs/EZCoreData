# EZCoreData

[![CI Status](https://img.shields.io/travis/CheesecakeLabs/EZCoreData.svg?style=flat)](https://travis-ci.org/marcelosalloum/EZCoreData)
[![Version](https://img.shields.io/cocoapods/v/EZCoreData.svg?style=flat)](https://cocoapods.org/pods/EZCoreData)
[![License](https://img.shields.io/cocoapods/l/EZCoreData.svg?style=flat)](https://cocoapods.org/pods/EZCoreData)
[![Platform](https://img.shields.io/cocoapods/p/EZCoreData.svg?style=flat)](https://cocoapods.org/pods/EZCoreData)

A library that builds up the basic main and private contexts for CoreData and brings a few utility methods

## Table of Contents
   * [EZCoreData](#ezcoredata)
      * [Example Project](#example-project)
      * [Installation](#installation)
      * [Usage](#usage)
         * [Set-up](#set-up)
         * [Count](#count)
         * [Create &amp; Save](#create--save)
         * [Get or Create](#get-or-create)
         * [Read First](#read-first)
         * [Read All](#read-all)
         * [Delete One](#delete-one)
         * [Delete All](#delete-all)
      * [Advanced Topics](#advanced-topics)
         * [ASYNC Methods](#async-methods)
         * [Import JSON into Objects](#import-json-into-objects)
         * [Error Handling:](#error-handling)
         * [NSManagedObjectContext](#nsmanagedobjectcontext)
      * [Files' Reference:](#files-reference)
      * [Author](#author)
      * [License](#license)

## Example Project

To run the example project, clone this repo, and run `pod install` from the Example directory first.

## Installation

EZCoreData is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'EZCoreData'
```

## Usage
### Set-up
There aree basically 2 ways of initiating EZCoreData. The recommended one is using the `EZCoreData.shared` instance:
```Swift
import EZCoreData

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Init Core Data
        EZCoreData.databaseName = "My_DB_Name"      // Initialize Core Data
        _ = EZCoreData.shared                       // Initialize Core Data
        return true
    }
...
}
```

Alternatively, you can save an instance of EZCoreData in a class of yours. AppDelegate, for instance:
```Swift
import EZCoreData

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var ezCoreData: EZCoreData!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Init Core Data
        ezCoreData = EZCoreData("My_DB_Namme") {
            // Handle completion
        }
        return true
    }
...
}
```

### Count
Alright, now that your core data is setup, let's run a simple count method. Supposing you have a NSManagedObject child called Article, you can count doing the following:
```Swift
let articleCount = Article.count()
```
Simple, right? BTW, you can pass a predicate here, so you count articles that conform to that predicate. For instance:
```Swift
let articleCount = Article.count(NSPredicate(format: "title CONTAINS[c] 'Art'"))
```

### Create & Save
```Swift
let newArticle = Article.create()
newArticle?.id = Int.random(in: 0...400)
newArticle?.managedObjectContext?.saveContextToStore()
```

### Get or Create
```Swift
let newOrExistingArticle = Article.getOrCreate(attribute: "id", value: 2, context: context)
newOrExistingArticle.title = "EZCoreData lib was finally launched, and it looks great!"
newOrExistingArticle.save()
```

### Read First
You can read the first object ay a given attribute:
```Swift
let article = Article.readFirst(attribute: "id", value: "123")
```
Or you can pass through your preferred predicate:
```Swift
let article = try Article.readFirst(NSPredicate(format: "id == 123"))
```
If you don't pass any predicate, the result will be the first Article in the CoreData.

### Read All
Likewise, you can geta list of objects either passing attributes:
```Swift
let articleList = Article.readAllByAttribute("title", value: "Art")
```
or predicates:
```Swift
let predicate = NSPredicate(format: "title CONTAINS[c] '\(searchTerm)' or authors CONTAINS[c] '\(searchTerm)'")
Article.readAll(predicate: predicate)
```
Like the other read methods, if you don't pass any predicate, the result will be the full list of Articles:
```Swift
let allArticles = Article.readAll()
```

### Delete One
```Swift
article.delete(context: context)
```

### Delete All
You can Delete All by doing:
```Swift
Article.deleteAll()
```
Or you can delete a subset:
```Swift
let remainingList = Article.readAll(predicate: NSPredicate(format: "title CONTAINS[c] 'Art'"))
Article.deleteAll(except: remainingList, context: context)
```

## Advanced Topics

### ASYNC Methods

Since the examples below illustrate only the SYNC functions (without the part of the try-catch error handling), Let's illustrate at least one ASYNC method to count as an example :D:
```Swift
Article.readFirst(attribute: "title", value: "Art") { (awesomeResult) in
    switch awesomeResult {
    case .success(result: let articlesList):
        print(articlesList!)                 // Do something with your list of articles
    case .failure(error: let error):
        print(error.localizedDescription)    // Handle your error
    }
}
```

### Import JSON into Objects

Supose we have a JSON array or maybe a JSON object that you'd like to import to your CoreData. To do so, you first need to override the method `open func populateFromJSON(_ json: [String: Any], context: NSManagedObjectContext)` in your `NSManagedObjectContext` child class. Like we do in your example project:
```Swift
import CoreData
import EZCoreData


public class Article: NSManagedObject {
    /// Populates Article objects from JSON
    public override func populateFromJSON(_ json: [String : Any], context: NSManagedObjectContext) {
        guard let rawId = json["id"]\ else { return }
        self.id = id
        self.title = json["title"] as? String

        guard let tags = json["tags"] as? [[String: Any]] else { return }
        do {
            guard let tagObjects = try Tag.importList(tags, idKey: "id", shouldSave: false, context: context) else { return }
            self.addToTags(NSSet(array: tagObjects))
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
```

After overriding the method `open func populateFromJSON(_ json: [String: Any], context: NSManagedObjectContext)`, you can import an object as simple as this:
```Swift
let jsonObject: [String: Any] = [
    "id": 1,
    "title": "EZCoreData lib was finally launched, and it looks great!"
]
let article = importObject(jsonObject, shouldSave: true)
```

To import list of objects from a JSON, simply do this:
```Swift
let jsonArray: [[String: Any]] = [
    [
        "id": 1,
        "title": "EZCoreData lib was finally launched, and it looks great!"
    ],
    [
        "id": 2,
        "title": "EZCoreData launch was delayed in 1 week"
    ],
]
let articlesList = Article.importList(jsonArray, idKey: "id", shouldSave: true)
```
You can check a sample code of this in this repo's example project.

### Error Handling:
Most functions in thislibrary have 2 versions: Syncronous and Asyncronous. Theyhandle erros in a different form:
**Syncronous Functions**: the SYNC functions throw the error so the user can handle it with a `do+try+catch` ou at least with a `try?` or `try!`.
**Asyncronous Functions**: the ASYNC functions deal with the error internally and then return the result in a very civilized completion handler, hich derives from the following ENUM:
```Swift
/// Handles any kind of results
public enum EZCoreDataResult<Object> {
    /// Handles success results
    case success(result: Object?)

    /// Handles failure results
    case failure(error: Error)
}
```

### NSManagedObjectContext

Th library was designed to run the SYNC tasks in the main thread and the ASYNC tasks on the bacground task. For that reason, there are two built-in `NSManagedObjectContexts` in the shared instance:
* `EZCoreData.shared.mainThreadContext`: Used in the lib for the SYNC methods. It's recommended to use the main context when the user is wasting his time waiting for a CoreData result.
* `EZCoreData.shared.privateThreadContext`: Used in the lib for the ASYNC methods. It's recommended to use background/private contexts when you perform a time-consuming task or when your user doesn't need to waste his time waiting for the result.

There is also the possibility of using your own NSMAnagedObjectContext in the convenience methods. All methods have an optonal parameter `context: NSManagedObjectContext` that is filled with one of the default contexts if you don't specify them. It's important to say that th pre-set contexts should work fine and there is Unit Tests to guarante that.

## Files' Reference:
- `EZCoreData`: used for managing the instances of the project's `NSPersistentContainer` and `NSManagedObjectContext`
- `EZCoreDataLogger`, used for holding the default ENUMs for LogLevel, Error and ResultCallback, as well as some convenient methods to manage logging (error, warning and info logging) 
- `NSManagedObjectContext+Save`: contains a convenience method (actually, sync and/or async versions of a method) for when you want to ensure the `privateThreadContext` saved changes will be propagated in its parent and siblings.
- `NSManagedObject+Create`: a set of convenience methods for creating and saving an Object
- `NSManagedObject+Read`: contains convenience methods to count objects and read list or single objects from the database
- `NSManagedObject+Update`: used to import objects to the database. Included the method `getOrCreate` as well
- `NSManagedObject+Delete`: used to delete a list of objects with the given characteristics, allowing the user to avoid deleting from a given list

## Author

marcelosalloum, marcelosalloum@gmal.com

## License

EZCoreData is available under the MIT license. See the LICENSE file for more info.
