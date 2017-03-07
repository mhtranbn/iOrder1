//
//  MaterialButton.swift
//  test
//
//  Created by mhtran on 5/22/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit

class MaterialButton: UIButton {

    override func awakeFromNib() {
        layer.cornerRadius = 6.0
        layer.borderColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.25).CGColor
        layer.borderWidth = 2
        
    }

}
