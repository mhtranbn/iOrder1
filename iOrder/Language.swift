//
//  language.swift
//  iOrder
//
//  Created by mhtran on 6/28/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit

class Language: NSObject {
    var name: String = ""
    var selected: Bool = false
    init(name: String) {
        self.name = name
//        self.selected = selected
    }
    deinit{
        print("is deinited")
    }
}
