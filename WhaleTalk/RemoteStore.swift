//
//  RemoteStore.swift
//  WhaleTalk
//
//  Created by Jeremy Sharvit on 2016-09-06.
//  Copyright © 2016 com.whaletalk. All rights reserved.
//

import Foundation
import CoreData

protocol RemoteStore {
    func signUp(phoneNumber phoneNumber: String, email: String, password:String, success: () -> (), errorCallback:(errorMessage: String) -> ())
    
    func startSyncing()
    
    func store(inserted inserter: [NSManagedObject], updated: [NSManagedObject], deleted: [NSManagedObject])
}