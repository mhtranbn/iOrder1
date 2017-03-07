//
//  ExtensionButton.swift
//  iOrder
//
//  Created by mhtran on 6/15/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import Foundation

extension UIButton{
    
    func setImage(image: UIImage?, inFrame frame: CGRect?, forState state: UIControlState){
        self.setImage(image, forState: state)
        
        if let frame = frame{
            self.imageEdgeInsets = UIEdgeInsets(
                top: frame.minY - self.frame.minY,
                left: frame.minX - self.frame.minX,
                bottom: self.frame.maxY - frame.maxY,
                right: self.frame.maxX - frame.maxX
            )
        }
    }
    
}