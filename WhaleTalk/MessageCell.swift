//
//  ChatCell.swift
//  WhaleTalk
//
//  Created by Jeremy Sharvit on 2016-04-17.
//  Copyright © 2016 com.whaletalk. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {

    let messageLabel:UILabel = UILabel()
    private let bubbleImageView = UIImageView()
    private var outgoingConstaints : [NSLayoutConstraint]!
    private var incomingConstaints : [NSLayoutConstraint]!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bubbleImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(bubbleImageView)
        bubbleImageView.addSubview(messageLabel)
        
        messageLabel.centerXAnchor.constraintEqualToAnchor(bubbleImageView.centerXAnchor).active = true
        messageLabel.centerYAnchor.constraintEqualToAnchor(bubbleImageView.centerYAnchor).active = true
        
        bubbleImageView.widthAnchor.constraintEqualToAnchor(messageLabel.widthAnchor, constant: 50).active = true
        bubbleImageView.heightAnchor.constraintEqualToAnchor(messageLabel.heightAnchor, constant: 20).active = true
        
        outgoingConstaints = [bubbleImageView.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor), bubbleImageView.leadingAnchor.constraintGreaterThanOrEqualToAnchor(contentView.centerXAnchor)]
        
        incomingConstaints = [bubbleImageView.leadingAnchor.constraintGreaterThanOrEqualToAnchor(contentView.leadingAnchor), bubbleImageView.trailingAnchor.constraintLessThanOrEqualToAnchor(contentView.centerXAnchor)]
        
        bubbleImageView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 10).active = true
        bubbleImageView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: -10).active = true
        
        
        //messageLabel.textAlignment = .Center
        messageLabel.numberOfLines = 0
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
    
    func incoming(incoming: Bool) {
        if incoming {
            messageLabel.textAlignment = .Left
            NSLayoutConstraint.deactivateConstraints(outgoingConstaints)
            NSLayoutConstraint.activateConstraints(incomingConstaints)
            bubbleImageView.image = bubble.incoming
        } else {
            messageLabel.textAlignment = .Right
            NSLayoutConstraint.deactivateConstraints(incomingConstaints)
            NSLayoutConstraint.activateConstraints(outgoingConstaints)
            bubbleImageView.image = bubble.outgoing
        }
    }

}


let bubble = makeBubble()

func makeBubble() -> (incoming: UIImage, outgoing: UIImage) {
    let image = UIImage(named: "MessageBubble")!
    let insetsIncoming = UIEdgeInsets(top: 17, left: 26.5, bottom: 17.5, right: 21)
    let insetsOutgoing = UIEdgeInsets(top: 17, left: 21, bottom: 17.5, right: 26.5)
    
    let outgoing = colorImage(image, red: 0/255, green: 122/255, blue: 255/255, alpha: 1).resizableImageWithCapInsets(insetsOutgoing)
    let flippedImage = UIImage(CGImage: image.CGImage!, scale: image.scale, orientation: UIImageOrientation.UpMirrored)
    
    let incoming = colorImage(flippedImage, red: 229/255, green: 229/255, blue: 229/255, alpha: 1).resizableImageWithCapInsets(insetsIncoming)
    
    return (incoming, outgoing)
}


func colorImage(image: UIImage, red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIImage {
    let rect = CGRect(origin: CGPointZero, size: image.size)
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
    let context = UIGraphicsGetCurrentContext()
    image.drawInRect(rect)
    CGContextSetRGBFillColor(context, red, green, blue, alpha)
    CGContextSetBlendMode(context, CGBlendMode.SourceAtop)
    CGContextFillRect(context, rect)
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return result
}











