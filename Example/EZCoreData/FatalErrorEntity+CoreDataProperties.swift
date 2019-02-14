//
//  FatalErrorEntity+CoreDataProperties.swift
//  EZCoreData_Example
//
//  Created by Marcelo Salloum dos Santos on 14/02/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//
//

import Foundation
import CoreData

extension FatalErrorEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FatalErrorEntity> {
        return NSFetchRequest<FatalErrorEntity>(entityName: "FatalErrorEntity")
    }

    @NSManaged public var id: Int16
}
