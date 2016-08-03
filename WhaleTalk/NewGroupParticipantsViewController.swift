//
//  NewGroupParticipantsViewController.swift
//  WhaleTalk
//
//  Created by Jeremy Sharvit on 2016-08-03.
//  Copyright © 2016 com.whaletalk. All rights reserved.
//

import UIKit
import CoreData

class NewGroupParticipantsViewController: UIViewController {

    
    var context:NSManagedObjectContext?
    var chat:Chat?
    var chatCreationDelegate:ChatCreationDelegate?
    private var searchField: UITextField!
    private let tableView = UITableView(frame: CGRectZero, style: .Plain)
    private let cellIdentifier = "ContactCell"
    
    private var displayedContacts = [Contact]()
    private var allContacts = [Contact]()
    private var selectedContacts = [Contact]()
    
    private var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        title = "Add Participants"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .Plain, target: self, action: #selector(self.createChat))
        showCreateButton(false)
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: CGRectZero)
        searchField = createSearchField()
        searchField.delegate = self
        tableView.tableHeaderView = searchField
        fillViewWith(tableView)
        
        if let context = context {
            let request = NSFetchRequest(entityName: "Contact")
            request.sortDescriptors = [NSSortDescriptor(key:"lastName", ascending: true),NSSortDescriptor(key:"firstName", ascending: true)]
            
            do {
                if let result = try context.executeFetchRequest(request) as? [Contact] {
                    allContacts = result
                }
            } catch {
                print("there was a problem fetching contacts")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func createSearchField() -> UITextField {
        let searchField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        searchField.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        searchField.placeholder = "Type contact name"
        
        let holderView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        searchField.leftView = holderView
        searchField.leftViewMode = .Always
        
        //this ignores the images color so you can manipulate its tint color
        let image = UIImage(named: "contact_icon")?.imageWithRenderingMode(.AlwaysTemplate)
        
        let contactImage = UIImageView(image: image)
        contactImage.tintColor = UIColor.darkGrayColor()
        
        holderView.addSubview(contactImage)
        contactImage.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints:[NSLayoutConstraint] = [
            contactImage.widthAnchor.constraintEqualToAnchor(holderView.widthAnchor, constant: -20),
            contactImage.heightAnchor.constraintEqualToAnchor(holderView.heightAnchor, constant: -20),
            contactImage.centerXAnchor.constraintEqualToAnchor(holderView.centerXAnchor),
            contactImage.centerYAnchor.constraintEqualToAnchor(holderView.centerYAnchor)
        ]
        
        NSLayoutConstraint.activateConstraints(constraints)
        
        return searchField
    }
    
    private func showCreateButton(show: Bool) {
        if show {
            navigationItem.rightBarButtonItem?.tintColor = view.tintColor
            navigationItem.rightBarButtonItem?.enabled = true
        } else {
            navigationItem.rightBarButtonItem?.tintColor = UIColor.lightGrayColor()
            navigationItem.rightBarButtonItem?.enabled = false
        }
    }
    
    func createChat() {
        guard let chat = chat, context = context else {return}
        chat.participants = NSSet(array: selectedContacts)
        chatCreationDelegate?.created(chat: chat, inContext: context)
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    private func endSearch() {
        displayedContacts = selectedContacts
        tableView.reloadData()
    }
}

extension NewGroupParticipantsViewController:UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedContacts.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        let contact = displayedContacts[indexPath.row]
        cell.textLabel?.text = contact.fullName
        cell.selectionStyle = .None
        return cell
    }
}

extension NewGroupParticipantsViewController:UITableViewDelegate {
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
            return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard isSearching else {return}
        let contact = displayedContacts[indexPath.row]
        
        guard !selectedContacts.contains(contact) else {return}
        selectedContacts.append(contact)
        allContacts.removeAtIndex(allContacts.indexOf(contact)!)
        searchField.text = ""
        endSearch()
        showCreateButton(true)
    }
}

extension NewGroupParticipantsViewController:UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        isSearching = true
        
        guard let currentText = textField.text else {
            endSearch()
            return true
        }
        
        let text = NSString(string: currentText).stringByReplacingCharactersInRange(range, withString: string)
        if text.characters.count == 0 {
            endSearch()
            return true
        }
        
        //this goes through all contacts and adds matches to displayed contacts
        displayedContacts = allContacts.filter{contact in
            let match = contact.fullName.rangeOfString(text) != nil
            return match
        }
        
        tableView.reloadData()
        return true
    }
}
