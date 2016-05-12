//
//  UIViewController+FillWithView.swift
//  WhaleTalk
//
//  Created by Jeremy Sharvit on 2016-05-12.
//  Copyright © 2016 com.whaletalk. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func fillViewWith(subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subview)
        
        let viewConstraints : [NSLayoutConstraint] = [
            subview.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor),
            subview.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
            subview.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
            subview.bottomAnchor.constraintEqualToAnchor(bottomLayoutGuide.topAnchor)
        ]
        
        NSLayoutConstraint.activateConstraints(viewConstraints)
    }
}