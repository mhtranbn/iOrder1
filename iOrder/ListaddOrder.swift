//
//  ListaddOrder.swift
//  iOrder
//
//  Created by mhtran on 6/6/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import Foundation
import UIKit

class ListaddOrder {
    var _id: String = ""
    var id: String {
        return _id
    }
    
    var _count: Int = 0
    var count:Int {
        return _count
    }
    
    var _image: String = ""
    var image: String{
    
        return _image
    }
    
    var _price: Int = 0
    var price: Int {
        return _price
    }
    
    var _name: String = ""
    var name:String {
        return _name
    }
    
    var _options: Dictionary<String,String> = Dictionary<String,String>()
    var options:Dictionary<String,String> {
        return _options
    }
    
    var _nameOV: Dictionary<String,String> = Dictionary<String,String>()
    var nameOV:Dictionary<String,String> {
        return _nameOV
    }
    
    var _description: String = ""
    var desription: String {
        return _description
    }
    
    init(id: String, count: Int, image: String, price: Int, name: String, options:Dictionary<String,String>, nameOV:Dictionary<String,String>, description: String) {
        self._id = id
        self._count = count
        self._image = image
        self._price = price
        self._name = name
        self._options = options
        self._nameOV = nameOV
        self._description = description
    }
    
    deinit {
        print("this class is deinit")
    }

}
