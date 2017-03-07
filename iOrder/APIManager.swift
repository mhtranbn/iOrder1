//
//  APIManager.swift
//  iOrder
//
//  Created by mhtran on 7/1/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import Foundation
import Alamofire
struct APIManager {
    #if local
    static let baseURLString = "http://123.30.238.231:85/api/" //Local Company
    #else
    static let baseURLString = "http://beta.iorder.io/api/" //Server company
    #endif
}