//
//  Syncer.swift
//  WhaleTalk
//
//  Created by Jeremy Sharvit on 2016-08-15.
//  Copyright © 2016 com.whaletalk. All rights reserved.
//

import UIKit
import CoreData

class Syncer: NSObject {
    private var mainContext:NSManagedObjectContext
    private var backgroundContext:NSManagedObjectContext
    
    init(mainContext: NSManagedObjectContext, backgroundContext: NSManagedObjectContext) {
        self.mainContext = mainContext
        self.backgroundContext = backgroundContext
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(mainContextSaved(_:)), name: NSManagedObjectContextDidSaveNotification, object: mainContext)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(backgroundContextSaved(_:)), name: NSManagedObjectContextDidSaveNotification, object: backgroundContext)
    }
    
    func mainContextSaved(notification: NSNotification) {
        backgroundContext.performBlock { 
            self.backgroundContext.mergeChangesFromContextDidSaveNotification(notification)
        }
    }
    
    func backgroundContextSaved(notification: NSNotification) {
        mainContext.performBlock { 
            self.mainContext.mergeChangesFromContextDidSaveNotification(notification)
        }
    }
    
    
}
