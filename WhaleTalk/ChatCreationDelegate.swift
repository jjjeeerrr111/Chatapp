//
//  ChatCreationDelegate.swift
//  WhaleTalk
//
//  Created by Jeremy Sharvit on 2016-05-13.
//  Copyright © 2016 com.whaletalk. All rights reserved.
//

import Foundation
import CoreData


protocol ChatCreationDelegate {
    
    func created(chat chat: Chat, inContext context: NSManagedObjectContext)
}