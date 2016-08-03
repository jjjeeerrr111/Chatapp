//
//  ContextViewController.swift
//  WhaleTalk
//
//  Created by Jeremy Sharvit on 2016-08-03.
//  Copyright © 2016 com.whaletalk. All rights reserved.
//

import Foundation
import CoreData

protocol ContextViewController {
    var context:NSManagedObjectContext? {get set}
}