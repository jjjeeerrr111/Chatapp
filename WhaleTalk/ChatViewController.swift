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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        for i in 0...10 {
            let m = Message()
            m.text = String(i)
            messages.append(m)
        }
        
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        view.addSubview(tableView)
        
        let tableViewConstraints : [NSLayoutConstraint] = [tableView.topAnchor.constraintEqualToAnchor(view.topAnchor), tableView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor), tableView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor), tableView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor)];
        
        NSLayoutConstraint.activateConstraints(tableViewConstraints)
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
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath:indexPath)
        let message = messages[indexPath.row]
        cell.textLabel?.text = message.text
        return cell
    }
}
