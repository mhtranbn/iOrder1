//
//  ContainerMyOrderVC.swift
//  iOrder
//
//  Created by mhtran on 5/17/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON

class ContainerMyOrderVC: ContainerVC {
    var segmentBool: Bool = false
    var flagJumpCurrent: Bool = false
    var indexBadges: NSInteger = 2
    override func viewDidLoad() {
        super.viewDidLoad()
        app = UIApplication.sharedApplication().delegate as? AppDelegate
        self.app.viewDict["ContainerMyOrderVC"] = self
        swipeableView.disableSwipe = true
//        self.hideBadge()
//        self.showBadge()
        UISetup()
        guard flagJumpCurrent != true else {
        self.swipeableView.jumpToCurrentOrderView()
            flagJumpCurrent = true
                
            return
        }
        self.swipeableView.jumpToMyOrderView()
        coreData = CoreData()
        managedObjectContext = coreData.managedObjectContext
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        showMenuBar()
    }
    
    func showBadge() {
        indexBadges += 1
        self.tabBarItem.badgeValue = "\(indexBadges)"
    }
    
    func hideBadge() {
        self.tabBarItem.badgeValue = nil
    }
   
    func UISetup() {
        titleBarDataSource = ["WAITING ORDER".localized(),"CURRENT ORDER".localized()]
        swipeableView.titleBarDataSource = titleBarDataSource
        swipeableView.delegate = self
        swipeableView.flagCenter = true
        swipeableView.buttonWidth = (self.view.frame.width / 2)
        swipeableView.viewFrame = CGRectMake(0.0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
        swipeableView.selectionBarHeight = 3.0 //For thin line
        swipeableView.segementBarHeight = 35.0 //Default is 44.0
        swipeableView.buttonPadding = 0 //Default is 8.0
        self.addChildViewController(swipeableView)
        self.view.addSubview(swipeableView.view)
        swipeableView.didMoveToParentViewController(self)
        app!.viewDict["ContainerMyOrderVC"] = self
    }
    
    
    override func didLoadViewControllerAtIndex(index: Int) -> UIViewController {

        switch index {
        case 0:
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier(SEGUE_CURRENT_ORDERVC) as? CurrentOrderVC
            return vc!
        default:
            let vc2 = self.storyboard!.instantiateViewControllerWithIdentifier(SEGUE_MYORDERVC) as? MyOrderVC
            return vc2!
            
        }
    }

  }
