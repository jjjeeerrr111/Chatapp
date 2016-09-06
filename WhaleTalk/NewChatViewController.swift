//
//  NewChatViewController.swift
//  WhaleTalk
//
//  Created by Jeremy Sharvit on 2016-05-12.
//  Copyright © 2016 com.whaletalk. All rights reserved.
//

import UIKit
import CoreData

class NewChatViewController: UIViewController, TableViewFetchedResultsDisplayer {

    var context:NSManagedObjectContext?
    private var fetchedResultsContoller:NSFetchedResultsController?
    private let tableView = UITableView(frame: CGRectZero, style: .Plain)
    private let cellIdentifier = "ContactCell"
    private var fetchedResultDelegate : NSFetchedResultsControllerDelegate?
    var chatCreationDelegate:ChatCreationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        // Do any additional setup after loading the view.
        title = "New Chat"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(NewChatViewController.cancel))
        automaticallyAdjustsScrollViewInsets = false
        
        self.fillViewWith(tableView)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        if let context = context {
            let request = NSFetchRequest(entityName: "Contact")
            request.sortDescriptors = [NSSortDescriptor(key: "lastName", ascending: true), NSSortDescriptor(key:"firstName",ascending: true)]
            fetchedResultsContoller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "sortLetter", cacheName: "NewChatViewController")
            fetchedResultDelegate = TableViewFetchedResultsDelegate(tableView: tableView, displayer: self)
            fetchedResultsContoller?.delegate = fetchedResultDelegate
            do {
                try fetchedResultsContoller?.performFetch()
            } catch {
                print("Problem fetching - NewChatViewController")
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        guard let contact = fetchedResultsContoller?.objectAtIndexPath(indexPath) as? Contact else {return}
        cell.textLabel?.text = contact.fullName
    }
}

extension NewChatViewController:UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sections = fetchedResultsContoller?.sections else {return nil}
        let currentSection = sections[section]
        return currentSection.name
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsContoller?.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsContoller?.sections else {return 0}
        let currentSection = sections[section]
        return currentSection.numberOfObjects
    }
    
}

extension NewChatViewController:UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let contact = fetchedResultsContoller?.objectAtIndexPath(indexPath) as? Contact else {return}
        guard let context = context else {return}
        let chat = Chat.existing(directWith: contact, inContext: context) ?? Chat.new(directWith: contact, inContext: context)
        chatCreationDelegate?.created(chat: chat, inContext: context)
        dismissViewControllerAnimated(false, completion: nil)
    }
}
