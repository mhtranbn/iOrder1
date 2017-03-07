//
//  AppDelegate.swift
//  iOrder
//
//  Created by mhtran on 4/15/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import CoreData
import Alamofire
import SwiftyJSON
import BRYXBanner
//import Stripe

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate  {

    var window: UIWindow?
    var viewDict: Dictionary<String,UIViewController> = Dictionary<String,UIViewController>()
    var genererValue: GenererValue = GenererValue()
    let navitabbar: NaviTabBar = NaviTabBar()
    var priceTotalOptions: Int = 0
    var priceItemsWithoutOption: Int = 0
    var number: Int = 1
    var cellLockSwipe: Bool = false
    var listOrder: [ListaddOrder] = []
    var listOptions : [Dictionary<String,AnyObject>] = []
    var option: options = options()
    var dataOrder: [Order] = []
    var flagJumpToMyOrderVC: Bool? = nil
    var flagJumpToMenuVC: Bool? = nil
    var flagsChangePassword: Bool? = nil
    var flagsScanWifi: Bool? = false
    var flagsBill: Bool? = false
    var countBagde:NSInteger = 0
    var numberOfBagde :Int = 9999
    var flagBadgeAnimate:Bool = false
    var flagsSearchVC: Bool = false
    var cPageIndex: Int = 0
    var optionChoose: Int = 1
    var optionValue:[Value] = []
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        /*
                 STPPaymentConfiguration.sharedConfiguration().publishableKey = "sk_test_BC2r3h68PeYZ2dc5UzVQXNlr"
         */
        UIApplication.sharedApplication().statusBarHidden = false
        UIApplication.sharedApplication().statusBarStyle = .LightContent
         //delay launchscreen
         let delay = 2.0
         NSThread.sleepForTimeInterval(delay)

        // Override point for customization after application launch.
        registerForPushNotifications(application)
        
        //log in with google+ 
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        GIDSignIn.sharedInstance().delegate = self
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            /* Code to show your tab bar controller */
        } else {
            /* code to show your login VC */
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
//        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
//        UINavigationBar.appearance().barStyle = .Black
////        UINavigationBar.appearance().barTintColor = UIColorFromRGBA("15E9A6", alpha: 1.0)
//        UINavigationBar.appearance().translucent = false
        let OnboardingViewControlelr = storyboard.instantiateViewControllerWithIdentifier("onboardingView")
        let ScanQRcode = storyboard.instantiateViewControllerWithIdentifier("xxx")
        if LocalStore.isFirstTime() == true {
            self.window!.rootViewController = ScanQRcode
        }else{
            self.window!.rootViewController = OnboardingViewControlelr
        }
        return FBSDKApplicationDelegate.sharedInstance()
            .application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func prefersStatusBarHidden(value: Bool) -> Bool {
        return false
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
                withError error: NSError!) {
                if (error == nil) {
        //             Perform any operations on signed in user here.
                    /*let userId = user.userID
                    let idToken = user.authentication.idToken // Safe to send to the server*/
                    let fullName = user.profile.name
                    /*let givenName = user.profile.givenName
                    let familyName = user.profile.familyName
                    let email = user.profile.email*/
                    // [START_EXCLUDE]
                    NSNotificationCenter.defaultCenter().postNotificationName(
                        "ToggleAuthUINotification",
                        object: nil,
                        userInfo: ["statusText": "Signed in user:\n\(fullName)"])
                    // [END_EXCLUDE]
                    //
                } else {
                    print("\(error.localizedDescription)")
                    // [START_EXCLUDE silent]
                    NSNotificationCenter.defaultCenter().postNotificationName(
                        "ToggleAuthUINotification", object: nil, userInfo: nil)
                    // [END_EXCLUDE]
                }
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
        if Defaults["scan"].boolValue == false && Defaults["login"].boolValue == true {
            APIManager.resetToken()
        }
        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
    }
    
    
    func application(application: UIApplication, openURL url: NSURL,
                     sourceApplication: String?, annotation: AnyObject) -> Bool {
        /*if #available(iOS 9.0, *) {
            var options: [String: AnyObject] = [UIApplicationOpenURLOptionsSourceApplicationKey: sourceApplication!,
                                                UIApplicationOpenURLOptionsAnnotationKey: annotation]
        } else {
            // Fallback on earlier versions
        }*/
        let googleDidHandle = GIDSignIn.sharedInstance().handleURL(url,
                                                                   sourceApplication: sourceApplication,
                                                                   annotation: annotation)
        
        let facebookDidHandle = FBSDKApplicationDelegate.sharedInstance()
            .application(application, openURL: url,
                         sourceApplication: sourceApplication, annotation: annotation)
        
        return facebookDidHandle || googleDidHandle
    }
    
    func registerForPushNotifications(application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(
            forTypes: [.Badge, .Sound, .Alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .None {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        print("Device Token:", tokenString)
        Defaults[.tokenDevice] = tokenString
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if application.applicationState == UIApplicationState.Inactive || application.applicationState == UIApplicationState.Background {
            //opened from a push notification when the app was on background
            
            // call myorderVC here
            self.flagJumpToMyOrderVC = true
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let containerVC = mainStoryboard.instantiateViewControllerWithIdentifier(SEGUE_CONTAINER) as! KYDrawerController
            let rootViewController = self.window!.rootViewController as! UINavigationController
            rootViewController.pushViewController({
                UIApplication.sharedApplication().applicationIconBadgeNumber = 0
                self.flagJumpToMyOrderVC = true
                return containerVC
                }(), animated: false)
        }
        if self.viewDict["MyOrderVC"] == nil {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(SEGUE_MYORDERVC) as! MyOrderVC
            self.viewDict["MyOrderVC"] = vc
        }
        (self.viewDict["MyOrderVC"] as! MyOrderVC).reload()
        
    }

    func application(application: UIApplication,  didReceiveRemoteNotification userInfo: [NSObject : AnyObject],  fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        if application.applicationState == .Active {
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            print("shdjgfhgjhgbk")
            print("Test notification open")
            let banner = Banner(title: "iOrder", subtitle: "Mệnh Lệnh Đã Được Cập Nhật.".localized(), image: UIImage(named: "IconBanner-Small.png"), backgroundColor: UIColor.blackColor())
            banner.springiness = .None
            banner.dismissesOnTap = true
            banner.show(duration: 7.0)
            AudioServicesPlaySystemSound(1312)
            banner.didTapBlock = {
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let containerVC = mainStoryboard.instantiateViewControllerWithIdentifier(SEGUE_CONTAINER) as! KYDrawerController
                let rootViewController = self.window!.rootViewController as! UINavigationController
                rootViewController.pushViewController({
                    self.flagJumpToMyOrderVC = true
                    return containerVC
                    }(), animated: false)
            }
            if self.viewDict["MyOrderVC"] == nil {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(SEGUE_MYORDERVC) as! MyOrderVC
                self.viewDict["MyOrderVC"] = vc
            }
            (self.viewDict["MyOrderVC"] as! MyOrderVC).reload()
        } else {
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            self.flagJumpToMyOrderVC = true
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let containerVC = mainStoryboard.instantiateViewControllerWithIdentifier(SEGUE_CONTAINER) as! KYDrawerController
            let rootViewController = self.window!.rootViewController as! UINavigationController
            rootViewController.pushViewController({
                UIApplication.sharedApplication().applicationIconBadgeNumber = 0
                self.flagJumpToMyOrderVC = true
                return containerVC
                }(), animated: false)
        
        if self.viewDict["MyOrderVC"] == nil {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(SEGUE_MYORDERVC) as! MyOrderVC
            self.viewDict["MyOrderVC"] = vc
        }
        (self.viewDict["MyOrderVC"] as! MyOrderVC).reload()
        }
    }

    func application(application:UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Failed to register:", error)
    }
}

