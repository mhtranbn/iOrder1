//
//  ContainerBillVC.swift
//  iOrder
//
//  Created by mhtran on 5/18/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON


class ContainerBillVC: ContainerVC {
    
    var flagJumpHistory: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if swipeableView.currentPageIndex == 0 {
            print("lsdkajfdksjf")
        }
        swipeableView.flagCenter = true
        
//        guard flagJumpHistory != true else {
//            
//            
//            self.swipeableView.jumpToMyOrderView()
//            flagJumpHistory = false
//            
//            return
//        }
        
        removeAllData()
        coreData = CoreData()
        managedObjectContext = coreData.managedObjectContext
        app = UIApplication.sharedApplication().delegate as? AppDelegate
        // REQUEST TO SERVER GET DATA OF BILL AND HISTORY
        //
        titleBarDataSource = ["NEW BILL".localized(),"HISTORY".localized()]
        // Do any additional setup after loading the view, typically from a nib.
        swipeableView.titleBarDataSource = titleBarDataSource
        swipeableView.delegate = self
        swipeableView.buttonWidth = (self.view.frame.width / 2)
        swipeableView.viewFrame = CGRectMake(0.0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
        swipeableView.selectionBarHeight = 3.0 //For thin line
        swipeableView.segementBarHeight = 35.0 //Default is 44.0
        swipeableView.buttonPadding = 0 //Default is 8.0
        self.addChildViewController(swipeableView)
        self.view.addSubview(swipeableView.view)
        swipeableView.didMoveToParentViewController(self)
        app!.viewDict["ContainerBillVC"] = self
    }
    
    override func didLoadViewControllerAtIndex(index: Int) -> UIViewController {
        switch index {
        case 0:
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier(SEGUE_NEWBILL_VC) as! NewBillVC
            return vc
        default:
            let vc2 = self.storyboard!.instantiateViewControllerWithIdentifier(SEGUE_HISTORY_VC) as! HistoryVC
            return vc2
            
        }
    }

    override func viewDidAppear(animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        app = UIApplication.sharedApplication().delegate as? AppDelegate
        showMenuBar()
    }
 
}
