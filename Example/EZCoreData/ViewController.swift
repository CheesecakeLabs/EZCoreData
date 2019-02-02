//
//  ViewController.swift
//  EZCoreData
//
//  Created by marcelosalloum on 01/22/2019.
//  Copyright (c) 2019 marcelosalloum. All rights reserved.
//

import UIKit
import EZCoreData
import Promise

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        EZCoreData.shared.setupPersistence("Model")
        print(EZCoreData.shared.mainThreadContext)
        print(EZCoreData.mainThreadContext)
        print(EZCoreData.shared.privateThreadContext)
//        print(EZCoreData.privateThreadContext)
        
        do {
            try print(Article.count(context: EZCoreData.mainThreadContext))
            
            Article.deleteAll().then({ (_) in
                return Article.create(shouldSave: true)
            }).then({ (article) in
                article.id = 10
                article.title = "My Title"
            }).then({ (article) in
                EZCoreData.mainThreadContext.saveContextToStore()
            }).then({ _ in
                try print(Article.count(context: EZCoreData.mainThreadContext))
            }).then({ _ in
                return Article.readAll()
            }).then({ articleList in
                print(articleList)
            }).then({ articleList in
                Article.deleteAll()
            }).then { (_) in
                print("Finished!")
            }
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

