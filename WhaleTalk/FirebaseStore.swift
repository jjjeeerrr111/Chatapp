//
//  FirebaseStore.swift
//  WhaleTalk
//
//  Created by Jeremy Sharvit on 2016-09-06.
//  Copyright © 2016 com.whaletalk. All rights reserved.
//

import Foundation
import Firebase
import CoreData

class FirebaseStore {
    private let context:NSManagedObjectContext
    private let rootRef = Firebase(url: "https://jeremywhaletalk.firebaseio.com")
    
    
    private var currentPhoneNumber:String? {
        set(phoneNumber) {
            NSUserDefaults.standardUserDefaults().setObject(phoneNumber, forKey: "phoneNumber")
        }
        
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey("phoneNumber") as? String
        }
    }
    
    init(context:NSManagedObjectContext) {
        self.context = context
    }
    
    func hasAuth() -> Bool {
        return rootRef.authData != nil
    }
}


extension FirebaseStore:RemoteStore {
    func startSyncing() {
        
    }
    
    func store(inserted inserter: [NSManagedObject], updated: [NSManagedObject], deleted: [NSManagedObject]) {
        
    }
    
    func signUp(phoneNumber phoneNumber: String, email: String, password: String, success: () -> (), errorCallback: (errorMessage: String) -> ()) {
        rootRef.createUser(email, password: password) { (error, result) in
            if error != nil {
                errorCallback(errorMessage: error.description)
            } else {
                let newUser = ["phoneNumber" : phoneNumber]
                self.currentPhoneNumber = phoneNumber
                let uid = result["uid"] as? String
                self.rootRef.childByAppendingPath("users").childByAppendingPath(uid).setValue(newUser)
                self.rootRef.authUser(email, password: password, withCompletionBlock: { (error, authData) in
                    if error != nil {
                        errorCallback(errorMessage: error.description)
                    } else {
                        success()
                    }
                })
            }
        }
    }
}