//
//  ViewController.swift
//  WhaleTalk
//
//  Created by Jeremy Sharvit on 2016-04-17.
//  Copyright © 2016 com.whaletalk. All rights reserved.
//

import UIKit
import CoreData

class ChatViewController: UIViewController {
    
    private let tableView = UITableView(frame: CGRectZero, style:.Grouped)
    
    private var sections = [NSDate:[Message]]()
    private var dates = [NSDate]()
    private let cellIdentifier = "Cell"
    private let newMessageField = UITextView()
    private var bottomConstraint : NSLayoutConstraint!
    var context: NSManagedObjectContext?
    var chat : Chat?
    
    private enum Error: ErrorType {
        case NoChat
        case NoContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        do {
            guard let chat = chat else {throw Error.NoChat}
            guard let context = context else {throw Error.NoContext}
            let request = NSFetchRequest(entityName: "Message")
            request.sortDescriptors = [NSSortDescriptor(key:"timestamp", ascending: false)]
            if let result = try context.executeFetchRequest(request) as? [Message] {
                for message in result {
                    addMessage(message)
                }
            }
        } catch {
            print("We couldn't fetch")
        }
        automaticallyAdjustsScrollViewInsets = false
        let newMessageArea = UIView()
        newMessageArea.backgroundColor = UIColor.lightGrayColor()
        newMessageArea.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newMessageArea)
        
        newMessageField.translatesAutoresizingMaskIntoConstraints = false
        newMessageField.scrollEnabled = false
        newMessageArea.addSubview(newMessageField)
        
        let sendButton = UIButton()
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", forState: .Normal)
        sendButton.setContentHuggingPriority(251, forAxis: .Horizontal)
        sendButton.setContentCompressionResistancePriority(751, forAxis: .Horizontal)
        sendButton.addTarget(self, action: #selector(self.pressedSend(_:)), forControlEvents: .TouchUpInside)
        newMessageArea.addSubview(sendButton)
        
        bottomConstraint = newMessageArea.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor)
        bottomConstraint.active = true
        
        let messageAreaConstaints : [NSLayoutConstraint] = [ newMessageArea.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor), newMessageArea.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor), newMessageField.leadingAnchor.constraintEqualToAnchor(newMessageArea.leadingAnchor, constant: 10), newMessageField.centerYAnchor.constraintEqualToAnchor(newMessageArea.centerYAnchor), sendButton.trailingAnchor.constraintEqualToAnchor(newMessageArea.trailingAnchor, constant: -10), newMessageField.trailingAnchor.constraintEqualToAnchor(sendButton.leadingAnchor, constant: -10), sendButton.centerYAnchor.constraintEqualToAnchor(newMessageField.centerYAnchor), newMessageArea.heightAnchor.constraintEqualToAnchor(newMessageField.heightAnchor, constant:20)]
        
        NSLayoutConstraint.activateConstraints(messageAreaConstaints)
        
        tableView.registerClass(MessageCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 44
        
        view.addSubview(tableView)
        
        let tableViewConstraints : [NSLayoutConstraint] = [tableView.topAnchor.constraintEqualToAnchor(view.topAnchor), tableView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor), tableView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor), tableView.bottomAnchor.constraintEqualToAnchor(newMessageArea.topAnchor)];
        
        NSLayoutConstraint.activateConstraints(tableViewConstraints)
        
        //add nsnotification center listener for keyboard popping up
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(self.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        //add nsnotification center listener for keyboard going down
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        //add UITapGesture to close keyboard
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapRecognizer)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.scrollToBottom()
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func updateBottomConstaint(notification: NSNotification) {
        if let userInfo = notification.userInfo, frame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue,animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
            
            let newFrame = view.convertRect(frame, fromView: (UIApplication.sharedApplication().delegate?.window)!)
            
            bottomConstraint.constant = newFrame.origin.y - CGRectGetHeight(view.frame)
            
            UIView.animateWithDuration(animationDuration, animations: {
                self.view.layoutIfNeeded()
            })
            tableView.scrollToBottom()
        }
    }
    
    func pressedSend(button: UIButton) {
        guard let text = newMessageField.text where text.characters.count > 0 else {return}
        
        guard let context = context else {return}
        guard let message = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: context) as? Message else {return}
        message.text = text
        message.isIncoming = false
        message.timestamp = NSDate()
        addMessage(message)
        do {
            try context.save()
        } catch {
            print("There was a problem saving")
            return
        }
        newMessageField.text = ""
        tableView.reloadData()
        tableView.scrollToBottom()
        view.endEditing(true)
    }
    
    func addMessage(message: Message) {
        guard let date = message.timestamp else {return}
        let calendar = NSCalendar.currentCalendar()
        let startDay = calendar.startOfDayForDate(date)
        
        var messages = sections[startDay]
        
        if messages == nil {
            dates.append(startDay)
            dates = dates.sort({$0.earlierDate($1) == $0})
            messages = [Message]()
        }
        messages!.append(message)
        messages?.sortInPlace{$0.timestamp!.earlierDate($1.timestamp!) == $0.timestamp}
        sections[startDay] = messages
    }
    
    
    //this will move the newMessageArea up when keyboard is shown by redrawing the view
    func keyboardWillShow(notification: NSNotification) {
        self.updateBottomConstaint(notification)
    }
    
    //this will move the newMessageArea down when keyboard will hide by redrawing the view
    func keyboardWillHide(notification: NSNotification) {
        self.updateBottomConstaint(notification)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ChatViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getMessages(section).count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dates.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath:indexPath) as! MessageCell
        let messages = getMessages(indexPath.section)
        let message = messages[indexPath.row]
        cell.messageLabel.text = message.text
        cell.incoming(message.isIncoming)
        //remove separator line
        cell.separatorInset = UIEdgeInsetsMake(0, tableView.bounds.size.width, 0, 0)
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func getMessages(section: Int) -> [Message] {
        let date = dates[section]
        return sections[date]!
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clearColor()
        let paddingView = UIView()
        view.addSubview(paddingView)
        paddingView.translatesAutoresizingMaskIntoConstraints = false
        let dateLabel = UILabel()
        paddingView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints: [NSLayoutConstraint] = [paddingView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor), paddingView.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor), dateLabel.centerXAnchor.constraintEqualToAnchor(paddingView.centerXAnchor), dateLabel.centerYAnchor.constraintEqualToAnchor(paddingView.centerYAnchor),paddingView.heightAnchor.constraintEqualToAnchor(dateLabel.heightAnchor, constant: 5), paddingView.widthAnchor.constraintEqualToAnchor(dateLabel.widthAnchor, constant: 10), view.heightAnchor.constraintEqualToAnchor(paddingView.heightAnchor)]
        
        NSLayoutConstraint.activateConstraints(constraints)
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM dd, YYYY"
        dateLabel.text = formatter.stringFromDate(dates[section])
        
        paddingView.layer.cornerRadius = 10
        paddingView.layer.masksToBounds = true
        paddingView.backgroundColor = UIColor(red: 153/255, green: 204/255, blue: 255/255, alpha: 1.0)
        return view
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

extension ChatViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
}
