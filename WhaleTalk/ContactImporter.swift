//
//  ContactImporter.swift
//  WhaleTalk
//
//  Created by Jeremy Sharvit on 2016-08-03.
//  Copyright © 2016 com.whaletalk. All rights reserved.
//

import Foundation
import CoreData
import Contacts

class ContactImporter {
    
    private var context:NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetch() {
        let store = CNContactStore()
        store.requestAccessForEntityType(.Contacts) { granted, error in
            
            if granted {
                do {
                    let request = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey])
                    try store.enumerateContactsWithFetchRequest(request, usingBlock: { (cnContact, stop) in
                        guard let contact = NSEntityDescription.insertNewObjectForEntityForName("Contact", inManagedObjectContext: self.context) as? Contact else {return}
                        contact.firstName = cnContact.givenName
                        contact.lastName = cnContact.familyName
                        contact.contactID = cnContact.identifier
                        print(contact)
                    })
                } catch let error as NSError {
                    print(error)
                } catch {
                    print("error with do-catch")
                }
            }
        }
    }
}