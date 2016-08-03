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

class ContactImporter : NSObject {
    
    private var context:NSManagedObjectContext
    private var lastCNNotificationTime:NSDate?
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }

    //listen to if permission to use contacts was revoked
    func listenForChanges() {
        CNContactStore.authorizationStatusForEntityType(.Contacts)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.addressBookDidChange(_:)), name: CNContactStoreDidChangeNotification, object: nil)
    }
    
    func addressBookDidChange(notification: NSNotification) {
        let now = NSDate()
        
        //this is a hack bc its being called twice - bug with sdk
        guard lastCNNotificationTime == nil || now.timeIntervalSinceDate(lastCNNotificationTime!) > 1 else {return}
        lastCNNotificationTime = now
        fetch()
    }
    
    //this reformats the number into a string and removes the blank spaces/"-" and parenthases
    func formatPhoneNumber(number: CNPhoneNumber) -> String {
       return number.stringValue.stringByReplacingOccurrencesOfString(" ", withString: "").stringByReplacingOccurrencesOfString("-", withString: "").stringByReplacingOccurrencesOfString("(", withString: "").stringByReplacingOccurrencesOfString(")", withString: "")
        
    }
    
    private func fetchExisting() -> (contacts: [String:Contact], phoneNumbers: [String:PhoneNumber]) {
        var contacts = [String:Contact]()
        var phoneNumbers = [String:PhoneNumber]()
        do {
            let request = NSFetchRequest(entityName: "Contact")
            request.relationshipKeyPathsForPrefetching = ["phoneNumbers"]
            if let contactsResult = try self.context.executeFetchRequest(request) as? [Contact] {
                for contact in contactsResult {
                    contacts[contact.contactID!] = contact
                    for phoneNumber in contact.phoneNumbers! {
                        phoneNumbers[phoneNumber.value] = phoneNumber as? PhoneNumber
                    }
                }
            }
        } catch {
            print("Error")
        }
        
        return (contacts,phoneNumbers)
    }
    
    func fetch() {
        let store = CNContactStore()
        store.requestAccessForEntityType(.Contacts) { granted, error in
            
            self.context.performBlock {
                if granted {
                    do {
                        
                        let (contacts,phoneNumbers) = self.fetchExisting()
                        
                        let request = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey])
                        try store.enumerateContactsWithFetchRequest(request, usingBlock: { (cnContact, stop) in
                            guard let contact = contacts[cnContact.identifier] ?? NSEntityDescription.insertNewObjectForEntityForName("Contact", inManagedObjectContext: self.context) as? Contact else {return}
                            contact.firstName = cnContact.givenName
                            contact.lastName = cnContact.familyName
                            contact.contactID = cnContact.identifier
                            for cnVal in cnContact.phoneNumbers {
                                guard let cnPhoneNumber = cnVal.value as? CNPhoneNumber else {continue}
                                guard let phoneNumber = phoneNumbers[cnPhoneNumber.stringValue] ?? NSEntityDescription.insertNewObjectForEntityForName("PhoneNumber", inManagedObjectContext: self.context) as? PhoneNumber else {continue}
                                phoneNumber.value = self.formatPhoneNumber(cnPhoneNumber)
                                phoneNumber.contact = contact
                            }
                        })
                        try self.context.save()
                    } catch let error as NSError {
                        print(error)
                    } catch {
                        print("error with do-catch")
                    }
                }
            }
        }
    }
}