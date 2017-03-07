//
//  LocalStore.swift
//  iOrder
//
//  Created by mhtran on 7/16/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import Foundation

struct LocalStore {
    static let userDefault = NSUserDefaults.standardUserDefaults()
    static func isFirstTime(isFirstTime:Bool) {
        userDefault.setBool(isFirstTime, forKey: "isFirstTime")
    }
    static func isFirstTime() -> Bool?{
        return userDefault.boolForKey("isFirstTime")
    }
    static func cleanUSer() {
        userDefault.removeObjectForKey("isFirstTime")
    }
}