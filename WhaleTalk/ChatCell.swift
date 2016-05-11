//
//  ChatCell.swift
//  WhaleTalk
//
//  Created by Jeremy Sharvit on 2016-05-11.
//  Copyright © 2016 com.whaletalk. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {

    let nameLabel = UILabel()
    let messageLabel = UILabel()
    let dateLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        nameLabel.font = UIFont.systemFontOfSize(18, weight: UIFontWeightBold)
        messageLabel.textColor = UIColor.grayColor()
        dateLabel.textColor = UIColor.grayColor()
        
        let labels = [nameLabel,messageLabel,dateLabel]
        
        for label in labels {
            label.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(label)
        }
        
        
        let contraints:[NSLayoutConstraint] = [
            nameLabel.topAnchor.constraintEqualToAnchor(contentView.layoutMarginsGuide.topAnchor),
            nameLabel.leadingAnchor.constraintEqualToAnchor(contentView.layoutMarginsGuide.leadingAnchor),
            messageLabel.bottomAnchor.constraintEqualToAnchor(contentView.layoutMarginsGuide.bottomAnchor),
            messageLabel.leadingAnchor.constraintEqualToAnchor(nameLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraintEqualToAnchor(contentView.layoutMarginsGuide.trailingAnchor),
            dateLabel.firstBaselineAnchor.constraintEqualToAnchor(nameLabel.firstBaselineAnchor)
        ]
        
        NSLayoutConstraint.activateConstraints(contraints)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
