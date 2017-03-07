//
//  APIPost.swift
//  iOrder
//
//  Created by mhtran on 7/1/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import CoreData

extension APIManager {
    static let app = UIApplication.sharedApplication().delegate as? AppDelegate
    enum Router: URLRequestConvertible {
        case CreateAcount([String:String])
        case Login([String:String])
        case ResetAcount([String:String])
        case LoginFaceBook([String:String])
        case LoginGoogle([String:String])
        case GetRestaurant(String)
        case GetBill
        case GetAllBills
        case CreatBill([String:[String]])
        case GetHistory(String)
        case GetDetailHistory(String)
        case CreateOrderItem([String:AnyObject])
        case CreateOrderListItem([String:AnyObject])
        case GetOrderItem
        case DeleteOrder(String)
        case ConfirmPayBill(String,[String:AnyObject])
        case GetAcount
        case CreateUpdateAcount()
        case CreateRegisterDevice([String:String])
        case CreateRemoveDevice([String:String])
        case CreateResetToken()
        case CreateChangePass([String:String])
        case CreateRate(String,[String:String])
        
        var URLRequest: NSMutableURLRequest {
            var method: Alamofire.Method {
                switch self {
                case .CreateAcount : return .POST
                case .Login: return .POST
                case .ResetAcount: return .POST
                case .LoginFaceBook: return .POST
                case .LoginGoogle: return .POST
                case .GetRestaurant: return .GET
                case .GetBill: return .GET
                case .GetAllBills: return .GET
                case .CreatBill: return .POST
                case .GetHistory: return .GET
                case .GetDetailHistory: return .GET
                case .CreateOrderItem: return .POST
                case .CreateOrderListItem: return .POST
                case .GetOrderItem: return .GET
                case .DeleteOrder: return .DELETE
                case .ConfirmPayBill: return .PATCH
                case .GetAcount: return .GET
                case .CreateUpdateAcount: return .POST
                case .CreateRegisterDevice: return .POST
                case .CreateRemoveDevice: return .DELETE
                case .CreateResetToken: return .GET
                case .CreateChangePass: return .POST
                case .CreateRate: return .PATCH
                }
            }

            let result:(path:String, paramters:[String:AnyObject]?) = {
                var token: String = "notoken"
                if KeychainSwift().get(TOKEN) != nil {
                    token = KeychainSwift().get(TOKEN)!
                }
                switch self {
                case .CreateAcount:
                    return ("users", nil)
                case .Login(let params):
                    return ("login", params)
                case .ResetAcount(let params):
                    return ("password/forgot", params)
                case .LoginFaceBook(let params):
                    return ("login/facebook", params)
                case .LoginGoogle(let params):
                    return ("login/google", params)
                case .GetRestaurant(let tableID):
                    return ("restaurants/table/\(tableID)", nil)
                case .GetBill():
                    return ("bills/new?token=\(token)", nil)
                case .GetAllBills():
                    return ("bills/new?same_table=1&token=\(token)", nil)
                case .GetHistory(let page):
                    return ("bills/history?include=restaurant&token=\(token)&page=\(page)",nil)
                case .GetDetailHistory(let tableID):
                    return ("bills/\(tableID)?include=user,orders,restaurant&token=\(token)",nil)
                case .CreateOrderItem(let params):
                    return ("orders?token=\(token)",params)
                case .CreateOrderListItem(let params):
                    return ("orders/store-orders?token=\(token)",params)
                case .GetOrderItem():
                    return ("orders?token=\(token)",nil)
                case .DeleteOrder(let idItem):
                    return ("orders/\(idItem)?token=\(token)",nil)
                case .CreatBill(let params):
                    return ("bills?token=\(token)",params)
                case .ConfirmPayBill(let billID, let params):
                    return ("bills/\(billID)?token=\(token)",params)
                case .GetAcount():
                    return ("users/profile?token=\(token)",nil)
                case .CreateUpdateAcount():
                    return ("users/profile?token=\(token)",nil)
                case .CreateRegisterDevice(let params):
                    return ("push-tokens/register?token=\(token)",params)
                case .CreateRemoveDevice(let params):
                    return ("push-tokens/remove?token=\(token)",params)
                case .CreateResetToken():
                    return ("token/refresh?token=\(token)",nil)
                case .CreateChangePass(let params):
                    return ("password?token=\(token)",params)
                case .CreateRate(let itemID, let params):
                    return ("items/\(itemID)/rate?token=\(token)",params)
                }
            }()
            let url = NSURL(string:APIManager.baseURLString + result.path)
            let URLRequest = NSMutableURLRequest(URL: url!) // bug here

            // get language of machine -> send to app
            URLRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            URLRequest.addValue("application/json", forHTTPHeaderField: "Accept")
            URLRequest.setValue("\(Localize.currentLanguage() )", forHTTPHeaderField: "Accept-Language")
            let encoding = Alamofire.ParameterEncoding.JSON
            let (encodedRequest, _) = encoding.encode(URLRequest, parameters: result.paramters)
            encodedRequest.HTTPMethod = method.rawValue
            return encodedRequest
        }
    }
    
    static func loginWithEmail(email:String, pass:String){
        let a = APIManager.Router.Login(
            ["email":"\(email)",
            "password": "\(pass)"
            ]).URLRequest
            Alamofire.request(a).responseJSON { (response) in
                if let value = response.result.value as? [String:AnyObject] {
                    let json = JSON(value)
                    print(json)
                    let app = UIApplication.sharedApplication().delegate as? AppDelegate
                    (app?.viewDict["LoginVC"] as! LoginVC).afterLogin(json)
                }
            }
    }
    
    static func resetAccount(email: String, callBack:(check: Int, error: String) -> Void) {
        let params = ["email":"\(email)"]
        let urlResquest = APIManager.Router.ResetAcount(params).URLRequest
        Alamofire.request(urlResquest).responseJSON { (response) in
            response.debugDescription
            if let value = response.result.value as? [String:AnyObject] {
                let json = JSON(value)
                print("\(json)")
                callBack(check: 1, error: "Error")
//                callBack(check: 0, error: "Done")
            } else {
                callBack(check: 1, error: "Error")
            }
        }
    }
    
    static func getDataFromTableID(tableID: String, callback:(index:Int,json:JSON) -> Void) -> Void {
        let urlResquest = APIManager.Router.GetRestaurant(tableID).URLRequest
        Alamofire.request(urlResquest).responseJSON { (response) in
            response.debugDescription
            if let value = response.result.value as? [String:AnyObject] {
                let json = JSON(value)
                print("ghhg=\(json["status_code"].rawString()!)")
                if json["status_code"].rawString()! != "null" {
                    callback(index: 0,json:nil) //show alert view
                } else {
                    callback(index:1, json: json)  // saveData
                }
            } else {
                callback(index:2, json: nil)  // print error alertView
            }
        }
    }
    
    static func loginSocialWithToken(accesssToken:String,social:String) {
        var urlResquest:NSMutableURLRequest!
        if social == "facebook" {
            urlResquest =  APIManager.Router.LoginFaceBook(["social_token" : "\(accesssToken)"]).URLRequest
        } else if social == "google" {
            urlResquest = APIManager.Router.LoginGoogle(["social_token" : "\(accesssToken)"]).URLRequest
        }        
        Alamofire.request(urlResquest).responseJSON(completionHandler: { (response) in
            if let value = response.result.value as? [String:AnyObject] {
                let json = JSON(value)
                let app = UIApplication.sharedApplication().delegate as? AppDelegate
                (app?.viewDict["LoginVC"] as! LoginVC).afterLogin(json)
            } else {
               print("asdfghjkl")
            }
        })
    }
    
    static func registerDeviceToServer() {
        let urlResquest = APIManager.Router.CreateRegisterDevice(["device_type": "ios",
            "device_token": "\(Defaults["tokenDevice"].stringValue)"])
        print(Defaults["tokenDevice"].stringValue)
        Alamofire.request(urlResquest).responseJSON(completionHandler: {
            (response) in
            if let value = response.result.value as? [String:AnyObject] {
                let json = JSON(value)
                print(json)
            }
            
        })        
    }
    
    static func createAcount(userNameSignUp:String,emailSignUp:String,phone:String,passwordSignUp:String,returnPaswordSignUp:String,callback:(check:Int,error:String)->Void) {
        let params = ["email":"\(emailSignUp)",
                      "phone":"\(phone)",
                      "password":"\(passwordSignUp)",
                      "name":"\(userNameSignUp)",
                      "password_confirmation":"\(returnPaswordSignUp)"
                      ]
        print(params)
        let urlRequest = NSURL(string:APIManager.baseURLString + "users")
        Alamofire.request(.POST, urlRequest!, parameters: params).responseJSON { (response) in
            var error: String = ""
            if let value = response.result.value as? [String: AnyObject] {
                let json = JSON(value)
                print(json)
                if json["errors"] != nil {
                    for (_,subJson):(String,JSON) in (json["errors"].dictionary)! {
                        error += subJson[0].string! + "\n"
                    }
                    callback(check: 0, error: error)
                } else {
                    APIManager.loginWithEmail(emailSignUp, pass: passwordSignUp)
                    callback(check: 2, error: "")
                }
            } else {
                error = "Network problem"
                callback(check: 1,error: error)
            }
        }
    }
    
    static func getBill() {
        let urlResquest = APIManager.Router.GetBill
        Alamofire.request(urlResquest).responseJSON(completionHandler: {
            (response) in
            if let value = response.result.value as? [String:AnyObject] {
                let json = JSON(value)
                let app = UIApplication.sharedApplication().delegate as! AppDelegate
                (app.viewDict["NewBillVC"] as! NewBillVC).saveData(json,kindOf: "single")
            }
        })
    }
    
    static func getAllbill() {
        let urlRequest = APIManager.Router.GetAllBills
        Alamofire.request(urlRequest).responseJSON(completionHandler: {
            (response) in
            if let value = response.result.value as? [String:AnyObject] {
                let json = JSON(value)
                let app = UIApplication.sharedApplication().delegate as! AppDelegate
                (app.viewDict["NewBillVC"] as! NewBillVC).saveData(json,kindOf: "group")
            }
        })
    }

    static func createNewBill(listIdOrder:[String], callBackBill:(index:Int,json:JSON) -> Void) {
        let urlRequest = APIManager.Router.CreatBill(["order_ids": listIdOrder])
        Alamofire.request(urlRequest).responseJSON(completionHandler: {
            (response) in
            if let value = response.result.value as? [String:AnyObject] {
                let json = JSON(value)
                print("json = \(json)")
                if json["bill"]["status"] == "unpaid" {
                    callBackBill(index: 0,json: json)
                } else {
                    callBackBill(index: 1,json: nil)
                }
            } else {
                callBackBill(index: 2,json: nil)
            }
        })
    }
    
    static func getHistory(page:String) {
        let urlrequest = APIManager.Router.GetHistory(page).URLRequest
        Alamofire.request(urlrequest).responseJSON { (response) in
            if let value = response.result.value as? [String:AnyObject] {
                let json = JSON(value)
                let app = UIApplication.sharedApplication().delegate as? AppDelegate
                (app?.viewDict["HistoryVC"] as! HistoryVC).saveData(json)
            }
        }
    }
    
    static func getDetailHistory(billID:String) {
        let urlRequest = APIManager.Router.GetDetailHistory(billID).URLRequest
        Alamofire.request(urlRequest).responseJSON { (response) in
            if let value = response.result.value as? [String:AnyObject] {
                let json = JSON(value)
                print("asdasdasd\(json)")
                let app = UIApplication.sharedApplication().delegate as? AppDelegate
                (app?.viewDict["DetailHistoryVC"] as! DetailHistoryVC).saveData(json)
            } else {
                print(response.result.value)
            }
        }
    }
    
    static func orderItem(params: [String:AnyObject]) {
        let urlRequest = APIManager.Router.CreateOrderItem(params).URLRequest
        Alamofire.request(urlRequest).responseJSON { (response) in
            if response.result.value as? [String:AnyObject] != nil {
                let json = JSON(response.result.value!)
                print(json)
//                APIManager.getOrderItems()
            }
        }
    }
    
    static func orderItemList(params: [String:AnyObject]) {
        let urlRequest = APIManager.Router.CreateOrderListItem(params).URLRequest
        Alamofire.request(urlRequest).responseJSON { (response) in
            if let value = response.result.value as? [String:AnyObject] {
                let json = JSON(value)

                if let error =  json["errors"].dictionary {
                    print(error)
                    return
                }
                let app = UIApplication.sharedApplication().delegate as? AppDelegate
                (app?.viewDict["CurrentOrderVC"] as! CurrentOrderVC).afterOrderList(json)
            }
        }
    }
    
    static func getOrderItems() {
        let urlRequest = APIManager.Router.GetOrderItem.URLRequest
        Alamofire.request(urlRequest).responseJSON { (response) in
            if let value = response.result.value as? [String:AnyObject] {
                let json = JSON(value)
                let app = UIApplication.sharedApplication().delegate as? AppDelegate
                (app?.viewDict["MyOrderVC"] as! MyOrderVC).saveData(json)
            }
        }
    }
    
    static func deleteOrderItem(idItem:String) {
        let urlRequest = APIManager.Router.DeleteOrder(idItem).URLRequest
        Alamofire.request(urlRequest).responseJSON { (response) in
            if let value = response.result.value as? [String:AnyObject] {
                let json = JSON(value)
                print(json)
            }
        }
    }
    
    static func confirmPay(billID:String,params:[String:AnyObject],callback: (error:String)->Void) {
        let urlRequest = APIManager.Router.ConfirmPayBill(billID,params).URLRequest
        Alamofire.request(urlRequest).responseJSON { (response) in
            if let value = response.result.value as? [String:AnyObject] {
                let json = JSON(value)
                if json["status_code"].rawString()! != "null" {
                    var error: String = ""
                    for (_,subJson):(String,JSON) in (json["errors"].dictionary)! {
                        error = subJson[0].string!
                        callback(error: error)
                    }
                print(json)
                }
            }
        }
    }
    
    static func getAcount(token: String, callback:(json:JSON)->Void) {
        let urlRequest = NSURL(string:APIManager.baseURLString + "users/profile?token=\(token)")
        Alamofire.request(.GET, urlRequest!).responseJSON { (response) in
//        Alamofire.request(urlRequest).responseJSON { (response) in
            if let value = response.result.value as? [String:AnyObject] {
                let json = JSON(value)
                print(json)
                callback(json: json)
            }
        }
    }
    
    static func updateAcount(token:String,params:[String:AnyObject],imgage:UIImageView,callback:(check:Int,json:JSON)->Void) {
        let urlRequest = NSURL(string:APIManager.baseURLString + "users/profile?token=\(token)")
        Alamofire.upload(.POST, urlRequest!, multipartFormData: {
            multipartFormData in
            if  let imageData = imgage.image?.resizeUnder(0.1).lowestQualityJPEGNSData {
                multipartFormData.appendBodyPart(data: imageData, name: "avatar", fileName: "file.png", mimeType: "image/png")
            }
            for (key, value) in params {
                multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
            }
            }, encodingCompletion: {
                encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        if let value = response.result.value as? [String:AnyObject] {
                            let json = JSON(value)
                            print(json)
                            callback(check: 1,json: json)
                        }
                    }
                case .Failure( _):
                    //Alert faild
                    callback(check: 2,json: nil)
                }
        })
    }
    
    static func removeDevice() {
        let token = KeychainSwift().get(TOKEN)!
        let params = [
            "device_type": "ios",
            "device_token": "\(Defaults["tokenDevice"].stringValue)"
        ]
        var urlRequest = NSURL(string:APIManager.baseURLString + "push-tokens/remove?token=\(token)")
        Alamofire.request(.DELETE, urlRequest!, parameters:params ).responseJSON { (response) in
            if let value = response.result.value as? [String:AnyObject] {
                let json = JSON(value)
                print(json)
                KeychainSwift().delete(TOKEN)
            }
        }
        urlRequest = nil
    }
    
    static func resetToken(){
        if KeychainSwift().get(TOKEN) == nil {
            KeychainSwift().set("NoToken", forKey: TOKEN)
        } else {
            print("NO")
//        var urlRequest = APIManager.Router.CreateResetToken().URLRequest
        Alamofire.request(APIManager.Router.CreateResetToken().URLRequest).responseJSON { (response) in
            if let value = response.result.value as? [String:AnyObject] {
                let json = JSON(value)
                print(json)
                if json["status_code"].int32 < 400 {
                    guard json["token"].string != "null" else{
                        return
                    }
                }
                KeychainSwift().set(json["token"].string!, forKey: TOKEN)
            
            }            
            }
//            urlRequest.
        }
    }
    
    static func changPass(name:String,email:String,currentPass:String,confirmPass:String,newPass:String,callback:(check:Int,error:String)->Void){
        let params = [
            "name":"\(name)",
            "email":"\(email)",
            "password": "\(currentPass)",
            "new_password_confirmation":"\(confirmPass)",
            "new_password":"\(newPass)"
            ]
        if currentPass == "" && newPass == "" && confirmPass == "" {
            callback(check: 1, error: "Please finish all field".localized())
        }
        let urlRequest = APIManager.Router.CreateChangePass(params).URLRequest
        Alamofire.request(urlRequest).responseJSON { (response) in
            if let value = response.result.value as? [String:AnyObject] {
                let json = JSON(value)
                print(json)
                guard json["status_code"].rawString() == "null" else {
                    let error: String = ""
                    guard json["errors"].rawString() == "null" else {
                        var error: String = ""
                        for (_,subJson):(String,JSON) in (json["errors"].dictionary)! {
                            error = subJson[0].string!
                        }
                        callback(check: 1,error: error)
                        return
                    }
                    callback(check: 1,error: "\(error)")
                    return
                }
                
                callback(check: 2,error: "")
            } else {
                callback(check: 1,error: "Network problem".localized())
            }
        }
    }
    
    static func createRate(itemId: String, params:[String:String], callBack: (check:Int,error:String)-> Void) {
        let token = KeychainSwift().get(TOKEN)!
        let urlRequest = NSURL(string: APIManager.baseURLString + "items/\(itemId)/rate?token=\(token)")
        Alamofire.request(.PATCH, urlRequest!, parameters: params).responseJSON { (response) in
            if let value = response.result.value as? [String:AnyObject] {
                let json = JSON(value)
                print(json)
                callBack(check: 0,error: "\(json.rawString()!)")
            } else {
                callBack(check: 1, error: "problem")
            }
        }
    }
    
}