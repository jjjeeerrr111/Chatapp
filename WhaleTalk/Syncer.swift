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
    var remoteStore:RemoteStore?
    
    init(mainContext: NSManagedObjectContext, backgroundContext: NSManagedObjectContext) {
        self.mainContext = mainContext
        self.backgroundContext = backgroundContext
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(mainContextSaved(_:)), name: NSManagedObjectContextDidSaveNotification, object: mainContext)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(backgroundContextSaved(_:)), name: NSManagedObjectContextDidSaveNotification, object: backgroundContext)
    }
    
    func mainContextSaved(notification: NSNotification) {
        backgroundContext.performBlock {
            
            let inserted = self.objectsForKey(NSInsertedObjectsKey, dictionary: notification.userInfo!, context: self.backgroundContext)
            let updated = self.objectsForKey(NSUpdatedObjectsKey, dictionary: notification.userInfo!, context: self.backgroundContext)
            let deleted = self.objectsForKey(NSDeletedObjectsKey, dictionary: notification.userInfo!, context: self.backgroundContext)
            self.backgroundContext.mergeChangesFromContextDidSaveNotification(notification)
            
            self.remoteStore?.store(inserted: inserted, updated: updated, deleted: deleted)
        }
    }
    
    func backgroundContextSaved(notification: NSNotification) {
        mainContext.performBlock {
            self.objectsForKey(NSUpdatedObjectsKey, dictionary: notification.userInfo!, context: self.mainContext).forEach{$0.willAccessValueForKey(nil)}
            self.mainContext.mergeChangesFromContextDidSaveNotification(notification)
        }
    }
    
    private func objectsForKey(key: String, dictionary: NSDictionary, context: NSManagedObjectContext) -> [NSManagedObject] {
        
        guard let set = dictionary[key] as? NSSet else {return []}
        guard let objects = set.allObjects as? [NSManagedObject] else {return []}
        
        return objects.map{context.objectWithID($0.objectID)}
    }
    
}
