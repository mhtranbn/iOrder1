//
//  ExtensionTabbar.swift
//  iOrder
//
//  Created by mhtran on 5/28/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import Foundation
import UIKit

extension UITabBar {
    
    override public func sizeThatFits(size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = TABBAR_HEIGHT
        return sizeThatFits
    }
}