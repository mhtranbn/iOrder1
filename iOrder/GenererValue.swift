//
//  GenererValue.swift
//  iOrder
//
//  Created by mhtran on 5/13/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit

class GenererValue: NSObject {

    var _table_id: String = ""
    var table_id: String {
        return _table_id
    }
    
    var _color: UIColor = UIColor(red: 215/255, green: 29/255, blue: 58/255, alpha: 1)
    var color: UIColor {
        return _color
    }
    
    var _total: Int = 0
    var total: Int {
        return _total
    }
    
    var _indexFirst: Int = 0
    var indexFirst: Int {
        return _indexFirst
    }
    
    var _colorMostOf: UIColor = UIColor(red: 45/255, green: 45/255, blue: 45/255, alpha: 1)
    var colorMostOf: UIColor {
        return _colorMostOf
    }
    
    override init() {
        super.init()
        self._table_id = table_id
        self._colorMostOf = colorMostOf
        self._color = color
        self._total = total
        self._indexFirst = indexFirst
    }
    
    deinit {
        print("the class denited")
    }

}
