//
//  ViewController.swift
//  EZCoreData
//
//  Created by marcelosalloum on 01/22/2019.
//  Copyright (c) 2019 marcelosalloum. All rights reserved.
//

import UIKit
import EZCoreData

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print(Date.today())
        
        EZCoreData.databaseName = "Model"
        _ = EZCoreData.shared
        print(EZCoreData.databaseName)
        print(EZCoreData.shared.persistentContainer)
        print(EZCoreData.shared.mainThredContext)
        print(EZCoreData.mainThredContext)
        print(EZCoreData.shared.privateThreadContext)
        print(EZCoreData.privateThreadContext)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

