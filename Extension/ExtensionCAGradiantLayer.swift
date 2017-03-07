//
//  ExtensionCAGradiantLayer.swift
//  iOrder
//
//  Created by mhtran on 7/16/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import Foundation
import UIKit

extension CAGradientLayer {
    
    func mainGardient() -> CAGradientLayer{
        let topColor = UIColorFromRGBA("13EA6E", alpha: 1.0)
        let bottomColor = UIColorFromRGBA("15E9A6", alpha: 1.0)
        
        let gardientColors: [CGColor] = [topColor.CGColor, bottomColor.CGColor]
        let gardientLocation: [CGFloat] = [0.0, 1.0]
        let gardientLayer: CAGradientLayer = CAGradientLayer()
        
        gardientLayer.colors = gardientColors
        gardientLayer.locations = gardientLocation
        
        return gardientLayer
    }
    
}