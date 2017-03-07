//
//  ContainerVC.swift
//  iOrder
//
//  Created by mhtran on 5/10/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit

import CoreData

class ContainerVC: UIViewController, SMSwipeableTabViewControllerDelegate ,NSFetchedResultsControllerDelegate {
    
    var customize = false
    var titleBarDataSource:[String] = []
    var app: AppDelegate! = nil
    let swipeableView = SMSwipeableTabViewController()
    var coreData = CoreData()
    var managedObjectContext: NSManagedObjectContext!
    func removeAllData() {
        titleBarDataSource.removeAll()
    }

    override func viewDidLoad() {
        app = UIApplication.sharedApplication().delegate as! AppDelegate
        app!.viewDict["ContainerVC"] = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.hidden = true
        app.navitabbar.showNaviTabBar()
    }
    
    //MARK: SMSwipeableTabViewController Delegate CallBack
    
    func didLoadViewControllerAtIndex(index: Int) -> UIViewController {
        switch index {
        case 0:
            return self
        
        default:
            
            return self
        }
    }
    
    func showMenuBar(){
        self.tabBarController?.tabBar.hidden = true
        app.navitabbar.showNaviTabBar()
    }
}
