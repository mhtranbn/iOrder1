//
//  StructUser.swift
//  iOrder
//
//  Created by mhtran on 6/27/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class UserClass {
    
     var avatar: String = ""
     var email: String = ""
     var name: String = ""
     var phone: String = ""
    
    static func parser(json:JSON) -> UserClass {
        let data = json["user"].dictionary!
        let user = UserClass()
        
        if data["avatar"]?.rawString()! != "null" {
            user.avatar = data["avatar"]!.string!
        }
        if data["email"]?.rawString()! != "null" {
            user.email = data["email"]!.string!
        }
        if data["name"]?.rawString()! != "null" {
            user.name = data["name"]!.string!
            
        }
        if data["phone"]?.rawString()! != "null" {
            user.phone = String(data["phone"]!.string!)
            
        }
        return user

    }
}