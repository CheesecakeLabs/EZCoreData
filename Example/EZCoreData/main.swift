//
//  main.swift
//  EZCoreData_Example
//
//  Created by Marcelo Salloum dos Santos on 22/01/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

let isRunningTests = NSClassFromString("XCTestCase") != nil
let appDelegateClass = isRunningTests ? nil : NSStringFromClass(AppDelegate.self)
let args = UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory(to: UnsafeMutablePointer<Int8>.self,
                                                                      capacity: Int(CommandLine.argc))
_ = UIApplicationMain(CommandLine.argc, args, nil, appDelegateClass)
