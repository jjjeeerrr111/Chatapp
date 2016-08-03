//
//  ContactsViewController.swift
//  WhaleTalk
//
//  Created by Jeremy Sharvit on 2016-08-03.
//  Copyright © 2016 com.whaletalk. All rights reserved.
//

import UIKit
import CoreData
import Contacts
import ContactsUI

class ContactsViewController: UIViewController, ContextViewController, TableViewFetchedResultsDisplayer, ContactSelector {
    
    var context: NSManagedObjectContext?
    
    private let tableView = UITableView(frame: CGRectZero, style: .Plain)
    private let cellIdentifier = "ContactCell"
    
    private var fetchedResultsController:NSFetchedResultsController?
    private var fetchedResultsDelegate:NSFetchedResultsControllerDelegate?
    
    private var searchController:UISearchController?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        navigationController?.navigationBar.topItem?.title = "All Contacts"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "add"), style: .Plain, target: self, action: #selector(self.newContact))
        automaticallyAdjustsScrollViewInsets = false
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.delegate = self
        tableView.dataSource = self
        fillViewWith(tableView)
        
        if let context = context {
            let request = NSFetchRequest(entityName: "Contact")
            request.sortDescriptors = [NSSortDescriptor(key:"lastName", ascending: true),  NSSortDescriptor(key:"firstName", ascending: true)]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "sortLetter", cacheName: nil)
            fetchedResultsDelegate = TableViewFetchedResultsDelegate(tableView: tableView, displayer: self)
            fetchedResultsController?.delegate = fetchedResultsDelegate
            
            do {
                try fetchedResultsController?.performFetch()
                
            } catch {
                print("there was a problem fetching")
            }
        }
        
        
        //this is how to display search results from another table view controller on top of this view
        //while the user is searching in the search bar
        let resultsVC = ContactsSearchResultsController()
        resultsVC.contactSelector = self
        resultsVC.contacts = fetchedResultsController?.fetchedObjects as! [Contact]
        searchController = UISearchController(searchResultsController: resultsVC)
        searchController?.searchResultsUpdater = resultsVC
        definesPresentationContext = true
        tableView.tableHeaderView = searchController?.searchBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        guard let contact = fetchedResultsController?.objectAtIndexPath(indexPath) as? Contact else {return}
        cell.textLabel?.text = contact.fullName
    }
    
    
    func newContact() {
        
    }
    
    func selectedContact(contact: Contact) {
        guard let id = contact.contactID else {return}
        let store = CNContactStore()
        let cnContact:CNContact
        do {
            cnContact = try store.unifiedContactWithIdentifier(id, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
        } catch {
            return
        }
        
        let vc = CNContactViewController(forContact: cnContact)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
        searchController?.active = false
    }

}

extension ContactsViewController:UITableViewDelegate {
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let contact = fetchedResultsController?.objectAtIndexPath(indexPath) as? Contact else {return}
        selectedContact(contact)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension ContactsViewController:UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else {return 0}
        let currentSection = sections[section]
        
        return currentSection.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sections = fetchedResultsController?.sections else {return nil}
        
        let currentSection = sections[section]
        
        return currentSection.name
    }
}