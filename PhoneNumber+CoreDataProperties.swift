//
//  PhoneNumber+CoreDataProperties.swift
//  WhaleTalk
//
//  Created by Jeremy Sharvit on 2016-08-03.
//  Copyright © 2016 com.whaletalk. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PhoneNumber {

    @NSManaged var value: String?
    @NSManaged var contact: Contact?

}