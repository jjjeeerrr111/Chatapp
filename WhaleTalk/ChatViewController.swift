//
//  ViewController.swift
//  WhaleTalk
//
//  Created by Jeremy Sharvit on 2016-04-17.
//  Copyright © 2016 com.whaletalk. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    
    private let tableView = UITableView()
    
    private var messages = [Message]()
    private let cellIdentifier = "Cell"
    private let newMessageField = UITextView()
    private var bottomConstraint : NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var localIncoming = true
        for i in 0...10 {
            let m = Message()
            //m.text = String(i)
            m.text = "This is a longer message.\(i)"
            m.incoming = localIncoming
            localIncoming = !localIncoming
            messages.append(m)
            
        }
        
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
        
        tableView.registerClass(ChatCell.self, forCellReuseIdentifier: cellIdentifier)
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
        }
    }
    
    func pressedSend(button: UIButton) {
        guard let text = newMessageField.text where text.characters.count > 0 else {return}
        
        let message = Message()
        message.text = text
        message.incoming = false
        messages.append(message)
        
        tableView.reloadData()
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow:tableView.numberOfRowsInSection(0)-1, inSection: 0), atScrollPosition: .Bottom, animated: true)
    }
    //this will move the newMessageArea up when keyboard is shown by redrawing the view
    func keyboardWillShow(notification: NSNotification) {
        self.updateBottomConstaint(notification)
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow:tableView.numberOfRowsInSection(0)-1, inSection: 0), atScrollPosition: .Bottom, animated: true)
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
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath:indexPath) as! ChatCell
        let message = messages[indexPath.row]
        cell.messageLabel.text = message.text
        cell.incoming(message.incoming)
        //remove separator line
        cell.separatorInset = UIEdgeInsetsMake(0, tableView.bounds.size.width, 0, 0)
        return cell
    }
}

extension ChatViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
}
