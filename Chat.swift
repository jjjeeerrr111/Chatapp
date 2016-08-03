//
//  Chat.swift
//  WhaleTalk
//
//  Created by Jeremy Sharvit on 2016-05-11.
//  Copyright © 2016 com.whaletalk. All rights reserved.
//

import Foundation
import CoreData


class Chat: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    var isGroupChat:Bool {
        return participants?.count > 1
    }
    
    var lastMessage:Message? {
        let request = NSFetchRequest(entityName: "Message")
        request.predicate = NSPredicate(format: "chat = %@", self)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit = 1
        
        do {
            guard let result = try self.managedObjectContext?.executeFetchRequest(request) as? [Message] else {return nil}
            
            return result.first
        } catch {
            print("Error for request")
        }
        
        return nil
    }
    
    func add(participant contact: Contact) {
        mutableSetValueForKey("participants").addObject(contact)
        
    }
    
}
