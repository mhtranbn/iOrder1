//
//  Grantdiant.swift
//  iOrder
//
//  Created by mhtran on 5/11/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import Foundation
import UIKit

class UIGradientImageView: UIImageView
{
    let myGradientLayer: CAGradientLayer
    
    override init(frame: CGRect){
        myGradientLayer = CAGradientLayer()
        super.init(frame: frame)
        self.setup()
        addGradientLayer()
    }
    
    func addGradientLayer(){
        if myGradientLayer.superlayer == nil{
            self.layer.addSublayer(myGradientLayer)
        }
    }
    
    required init(coder aDecoder: NSCoder){
        myGradientLayer = CAGradientLayer()
        super.init(coder: aDecoder)!
        self.setup()
        addGradientLayer()
    }
    
    func getColors() -> [CGColorRef] {
        return [UIColor.clearColor().CGColor, UIColor(red: 0, green: 0, blue: 0, alpha: 0.6).CGColor]
    }
    
    func getLocations() -> [CGFloat]{
        return [0.4,  0.9]
    }
    
    func setup() {
        myGradientLayer.startPoint = CGPoint(x: 0.6, y: 0)
        myGradientLayer.endPoint = CGPoint(x: 0.6, y: 1)
        
        let colors = getColors()
        myGradientLayer.colors = colors
        myGradientLayer.opaque = false
        myGradientLayer.locations = getLocations()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        myGradientLayer.frame = self.layer.bounds
    }
}