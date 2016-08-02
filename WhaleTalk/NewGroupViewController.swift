//
//  NewGroupViewController.swift
//  WhaleTalk
//
//  Created by Jeremy Sharvit on 2016-08-02.
//  Copyright © 2016 com.whaletalk. All rights reserved.
//

import UIKit
import CoreData

class NewGroupViewController: UIViewController {

    
    var context:NSManagedObjectContext?
    var chatCreationDelegate:ChatCreationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "New Group"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
