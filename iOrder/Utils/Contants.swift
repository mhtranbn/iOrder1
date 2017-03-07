//
//  Contants.swift
//  iOrder
//
//  Created by mhtran on 4/15/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import Foundation
import UIKit

let SEGUE_LOGGED_IN = "LoginVC"
let SEGUE_FORGOT_PASS = "PasswordResetVC"
let SEGUE_SIGN_UP = "SignUpVC"
let SEGUE_HOME_VC = "HomeVC"
let SEGUE_SCANQRCODE = "ScanQRCodeVC"
let SEGUE_MYORDERVC = "MyOrderVC"
let SEGUE_CURRENT_ORDERVC = "CurrentOrderVC"
let SEGUE_CONTAINER_MENU = "ContainerMenuVC"
let SEGUE_CONTAINER = "KYDrawerController"
let SEGUE_TABBAR_CUSTOM = "RAMAnimatedTabBarController"
let SEGUE_DETAILITEMSVC = "DetailItemVC"
let SEGUE_LIST_ITIEMS = "MenuVC"
let SEGUE_CONTAINER_ORDER = "ContainerMyOrderVC"
let SEGUE_SEARCHCONTROLLER = "SearchVC"
let SEGUE_CONTAINER_BILL = "ContainerBillVC"
let SEGUE_NEWBILL_VC = "NewBillVC"
let SEGUE_HISTORY_VC = "HistoryVC"
let SEGUE_SOCIAL_VC = "FaceBookTwitterVC"
let SEGUE_PAY_VC = "PayVC"
let SEGUE_DETAIL_HISTORY = "DetailHistoryVC"
let SEGUE_ACOUNT = "AcountVC"
let SEGUE_CHANGEPASS = "ChangePassVC"
let SEGUE_LANGUAGE = "Languages"
let SEGUE_SCAN_WIFI = "ScanWifi"
let DRINK_VC = "DrinkVC"
let PIZZA_VC = "PizzaVC"
let BERGER_VC = "BergerVC"
let FRUITS_VC = "FruitsVC"
let COLOR_EX: String = "#FF6600"
let EMAIL: String = "email"
let PASS: String = "pass"
let TOKEN: String = "token"

var TABBAR_HEIGHT = CGFloat(60)
extension DefaultsKeys {
    static let login = DefaultsKey<Bool?>("login")
    static let scan = DefaultsKey<Bool?>("scan")
    static let tokenDevice = DefaultsKey<String?>("tokenDevice")
    static let languageCurrent = DefaultsKey<AnyClass?>("languageCurrent")
}
