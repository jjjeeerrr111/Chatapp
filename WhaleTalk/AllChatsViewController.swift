//
//  AllChatsViewController.swift
//  WhaleTalk
//
//  Created by Jeremy Sharvit on 2016-05-11.
//  Copyright © 2016 com.whaletalk. All rights reserved.
//

import UIKit
import CoreData

class AllChatsViewController: UIViewController, TableViewFetchedResultsDisplayer, ChatCreationDelegate {
    
    var context:NSManagedObjectContext?
    private var fetchedResultsController:NSFetchedResultsController?
    private let tableView = UITableView(frame: CGRectZero, style: .Plain)
    private let cellIdentifier = "MessageCell"
    private var fetchedResultDelegate : NSFetchedResultsControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Chats"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "new-chat"), style: .Plain, target: self, action: #selector(AllChatsViewController.newChat))
        automaticallyAdjustsScrollViewInsets = false
        self.fillViewWith(tableView)
        tableView.registerClass(ChatCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.tableHeaderView = createHeader()
        tableView.dataSource = self
        tableView.delegate = self
        
        if let context = context {
            let request = NSFetchRequest(entityName: "Chat")
            request.sortDescriptors = [NSSortDescriptor(key: "lastMessageTime", ascending: false)]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultDelegate = TableViewFetchedResultsDelegate(tableView: tableView, displayer: self)
            fetchedResultsController?.delegate = fetchedResultDelegate
            do {
                try fetchedResultsController?.performFetch()
            } catch {
                print("There was a problem fetching - allchatsviewcontroller")
            }
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func newChat() {
        let vc = NewChatViewController()
        let chatContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        chatContext.parentContext = context
        vc.context = chatContext
        vc.chatCreationDelegate = self
        let navVC = UINavigationController(rootViewController: vc)
        presentViewController(navVC, animated: true, completion: nil)
    }
    
    func fakeData() {
        guard let context = context else {return}
        let chat = NSEntityDescription.insertNewObjectForEntityForName("Chat", inManagedObjectContext: context) as? Chat
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let cell = cell as! ChatCell
        guard let chat = fetchedResultsController?.objectAtIndexPath(indexPath) as? Chat else {return}
        guard let contact = chat.participants?.anyObject() as? Contact else {return}
        guard let lastMessage = chat.lastMessage, timestamp = lastMessage.timestamp, text = lastMessage.text else {return}
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        cell.nameLabel.text = contact.fullName
        cell.dateLabel.text = formatter.stringFromDate(timestamp)
        cell.messageLabel.text = text
    }
    
    func created(chat chat: Chat, inContext context: NSManagedObjectContext) {
        let vc = ChatViewController()
        vc.context = context
        vc.chat = chat
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func createHeader() -> UIView {
        let header = UIView()
        let newGroupButton = UIButton()
        newGroupButton.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(newGroupButton)
        
        newGroupButton.setTitle("New Group", forState: .Normal)
        newGroupButton.setTitleColor(view.tintColor, forState: .Normal)
        newGroupButton.addTarget(self, action: #selector(self.pressedNewGroup), forControlEvents: .TouchUpInside)
        
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(border)
        border.backgroundColor = UIColor.lightGrayColor()
        
        
        let contraints:[NSLayoutConstraint] = [
            newGroupButton.heightAnchor.constraintEqualToAnchor(header.heightAnchor),
            newGroupButton.trailingAnchor.constraintEqualToAnchor(header.layoutMarginsGuide.trailingAnchor),
            border.heightAnchor.constraintEqualToConstant(1),
            border.leadingAnchor.constraintEqualToAnchor(header.leadingAnchor),
            border.trailingAnchor.constraintEqualToAnchor(header.trailingAnchor),
            border.bottomAnchor.constraintEqualToAnchor(header.bottomAnchor)
        ]
        
        NSLayoutConstraint.activateConstraints(contraints)
        
        //the following lines of code determine the smallest size of the header frame based on the contents
        //of the header view - brilliant
        header.setNeedsLayout()
        header.layoutIfNeeded()
        
        let height = header.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        var frame  = header.frame
        frame.size.height = height
        header.frame = frame
        
        return header
    }
    
    func pressedNewGroup() {
        
        
    }
    
}

extension AllChatsViewController:UITableViewDataSource {
    
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
}


extension AllChatsViewController:UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let chat = fetchedResultsController?.objectAtIndexPath(indexPath) as? Chat else {return}
        let vc = ChatViewController()
        vc.context = context
        vc.chat = chat
        navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}