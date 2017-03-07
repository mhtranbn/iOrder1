//
//  NaviTabBar.swift
//  iOrder
//
//  Created by mhtran on 6/26/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit
import Foundation
class NaviTabBar: NSObject {

    var app : AppDelegate!
    
    func setTitleBar(title: String) {
        app = UIApplication.sharedApplication().delegate as! AppDelegate
        (app.viewDict["KYDrawerController"] as! KYDrawerController).titleNaVi.text = title
    }
    
    func showSearchBar(){
        app = UIApplication.sharedApplication().delegate as! AppDelegate
        (app.viewDict["KYDrawerController"] as! KYDrawerController).searchBar.hidden = false
        
    }
    func hideSearchBar(){
        app = UIApplication.sharedApplication().delegate as! AppDelegate
        (app.viewDict["KYDrawerController"] as! KYDrawerController).searchBar.hidden = true
    }

    func showNaviTabBar(){
        app = UIApplication.sharedApplication().delegate as! AppDelegate
        for (_,view) in app.viewDict {
            view.tabBarController?.tabBar.hidden = true
            view.navigationController?.setNavigationBarHidden(true, animated: false)
//            view.navigationController?.navigationController?.setNavigationBarHidden(true, animated: false)
        }
        (app.viewDict["KYDrawerController"] as! KYDrawerController).naviCustom.hidden = false
        (app.viewDict["RAMAnimatedTabBarController"] as! RAMAnimatedTabBarController).animationTabBarHidden(false)
//        (app.viewDict["RAMAnimatedTabBarController"] as! RAMAnimatedTabBarController).hidesBottomBarWhenPushed = true
    }

    func hideNaviBarTabbar(){
        app = UIApplication.sharedApplication().delegate as! AppDelegate
        for (_,view) in app.viewDict {
            view.tabBarController?.tabBar.hidden = true
            view.navigationController?.setNavigationBarHidden(true, animated: false)
        }
        (app.viewDict["KYDrawerController"] as! KYDrawerController).naviCustom.hidden = true
        (app.viewDict["RAMAnimatedTabBarController"] as! RAMAnimatedTabBarController).animationTabBarHidden(true)
    }
    
}
