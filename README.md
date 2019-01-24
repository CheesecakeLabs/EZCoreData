# EZCoreData

[![CI Status](https://img.shields.io/travis/marcelosalloum/EZCoreData.svg?style=flat)](https://travis-ci.org/marcelosalloum/EZCoreData)
[![Version](https://img.shields.io/cocoapods/v/EZCoreData.svg?style=flat)](https://cocoapods.org/pods/EZCoreData)
[![License](https://img.shields.io/cocoapods/l/EZCoreData.svg?style=flat)](https://cocoapods.org/pods/EZCoreData)
[![Platform](https://img.shields.io/cocoapods/p/EZCoreData.svg?style=flat)](https://cocoapods.org/pods/EZCoreData)

A library that builds up the basic main and private contexts for CoreData and brings a few utility methods

## Brief Reference:
- `EZCoreData`: used for managing the instances of the project's `NSPersistentContainer` and `NSManagedObjectContext`
- `EZCoreDataLogger`, used for holding the default ENUMs for LogLevel, Error and ResultCallback, as well as some convenient methods to manage logging (error, warning and info logging) 
- `NSManagedObjectContext+Save`: contains a convenience method (actually, sync and/or async versions of a method) for when you want to ensure the `privateThreadContext` saved changes will be propagated in its parent and siblings.
- `NSManagedObject+Create`: a set of convenience methods for creating and saving an Object
- `NSManagedObject+Read`: contains convenience methods to count objects and read list or single objects from the database
- `NSManagedObject+Update`: used to import objects to the database. Included the method `getOrCreate` as well
- `NSManagedObject+Delete`: used to delete a list of objects with the given characteristics, allowing the user to avoid deleting from a given list

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

EZCoreData is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'EZCoreData'
```

## Usage
### EZCoreData setup
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

Alternatively, you can savve an instance of EZCoreData in a class of yours. AppDelegate, for instance:
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
let articleCount = try? Article.count(context: EZCoreData.mainThredContext)
```
Simple, right? BBTW, since the method throws an error, I've used the `try?` syntax in this example. I encourage you to use de do/catch syntax to handle the error properly

### Create & Save

```Swift
let newArticle = Article.create()
newArticle.id = Int.random(in: 0...400)
newArticle.save()
```

### [TODO] ReadFirst, ReadAll

### [TODO] Delete, DeleteAll

### [TODO] getOrCreate, import (and override models)


## Author

marcelosalloum, marcelosalloum@gmal.com

## License

EZCoreData is available under the MIT license. See the LICENSE file for more info.
