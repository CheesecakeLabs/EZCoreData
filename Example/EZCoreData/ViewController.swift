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
        
        EZCoreData.shared.setupPersistence("Model")
        print(EZCoreData.shared.mainThredContext)
        print(EZCoreData.mainThredContext)
        print(EZCoreData.shared.privateThreadContext)
        print(EZCoreData.privateThreadContext)
        
        do {
            try print(Article.count(context: EZCoreData.mainThredContext))
            try Article.deleteAll(context: EZCoreData.mainThredContext)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

