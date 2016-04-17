//
//  UITableView+Scroll.swift
//  WhaleTalk
//
//  Created by Jeremy Sharvit on 2016-04-17.
//  Copyright © 2016 com.whaletalk. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    //extend the table view to scroll to bottom when this function is called
    func scrollToBottom() {
        if self.numberOfSections > 1 {
            let lastSection = self.numberOfSections - 1
            self.scrollToRowAtIndexPath(NSIndexPath(forRow: self.numberOfRowsInSection(lastSection)-1, inSection:lastSection), atScrollPosition: .Bottom, animated: true)
        } else if numberOfRowsInSection(0) > 0 && self.numberOfSections == 1 {
            self.scrollToRowAtIndexPath(NSIndexPath(forRow:self.numberOfRowsInSection(0)-1, inSection: 0), atScrollPosition: .Bottom, animated: true)
        }
    }
    
}