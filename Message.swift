//
//  Message.swift
//  WhaleTalk
//
//  Created by Jeremy Sharvit on 2016-05-11.
//  Copyright © 2016 com.whaletalk. All rights reserved.
//

import Foundation
import CoreData


class Message: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    var isIncoming :Bool {
        return sender != nil
    }
    
}
