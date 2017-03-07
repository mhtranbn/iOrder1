//
//  DataOrder.swift
//  iOrder
//
//  Created by mhtran on 5/20/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import Foundation
import UIKit

class DataOrder {
    var _linkImage: String! = ""
    var linkImage : String {
        return _linkImage
    }
    
    var _name: String! = ""
    var name : String {
        return _name
    }
    
    var _quantity: Int! = 0
    var quantity : Int {
        return _quantity
    }
    
    var _price: Int! = 0
    var price : Int {
        return _price

    }
    
    var _status: String! = ""
    var status: String {
        return _status
    }
    
    var _id: String! = ""
    var id: String {
        return _id
    }
    

    init (link: String, name: String, quantity: Int, price: Int, status: String, id: String) {
        self._linkImage = link
        self._name = name
        self._quantity = quantity
        self._price = price
        self._status = status
        self._id = id

    }
    
    
}