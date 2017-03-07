//
//  MyFooter.swift
//  iOrder
//
//  Created by mhtran on 7/7/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit

class MyFooter: UIView {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        self.activityIndicator.startAnimating()
    }
}