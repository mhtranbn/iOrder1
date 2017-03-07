//
//  Grantdiant2.swift
//  test
//
//  Created by mhtran on 5/22/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

//
//  Grantdiant.swift
//  iOrder
//
//  Created by mhtran on 5/11/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import Foundation
import UIKit

class UIGradientImageView2: Grantdiant3 {
    

    override func getColors() -> [CGColorRef] {
        return [UIColor.clearColor().CGColor, UIColor(red: 1, green: 1, blue:1, alpha: 0.3).CGColor]
    }
}