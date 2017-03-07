//
//  Grantdiant3.swift
//  iOrder
//
//  Created by mhtran on 5/23/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import Foundation
import UIKit

class Grantdiant3: UIGradientImageView {
    
    override func getLocations() -> [CGFloat]{
        return [0,  1]
    }
    
    override func setup() {
        myGradientLayer.startPoint = CGPoint(x: 1, y: 1)
        myGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        myGradientLayer.masksToBounds = true
        myGradientLayer.cornerRadius = 0
        let colors = getColors()
        myGradientLayer.colors = colors
        myGradientLayer.opaque = false
        myGradientLayer.locations = getLocations()
    }
    
}