//
//  LetfMenuVC.swift
//  iOrder
//
//  Created by mhtran on 5/25/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON

class LetfMenuVC: UIViewController,UITableViewDelegate, UITableViewDataSource,NSFetchedResultsControllerDelegate {
    
    var array = ["SCAN-TABLE".localized(),"SCAN-WIFI".localized(),"ACCOUNT".localized(),"LOGIN".localized(),"PASSWORD".localized(),"LANGUAGE".localized(), "HELP".localized()]
    
    var app: AppDelegate? = nil
    var keychain = KeychainSwift()
    var result: NSFetchedResultsController? = nil
    
    @IBOutlet weak var headerLeftMenu: UIView!
    @IBOutlet weak var name: UILabel!
    var isHidden: Bool = false
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        app = UIApplication.sharedApplication().delegate as? AppDelegate
        self.headerLeftMenu.backgroundColor = app?.genererValue.color
        self.navigationController?.navigationBar.hidden = true
        self.tabBarController?.tabBar.hidden = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        app!.viewDict["LetfMenuVC"] = self
        tableView.tableFooterView = UIView()
        
    }
    
    func reloadData() {
        if Defaults["login"].boolValue == true {
            array[3] = "LOGOUT".localized()
        } else {
            array[3] = "LOGIN".localized()
        }
        self.tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        _ = indexPath.row
        let menu = array[indexPath.row]
        cell.textLabel?.text = "     " + menu
        cell.textLabel?.font = UIFont.systemFontOfSize(18)  //UIFont(name: "Nexa Bold", size: 18)
        self.tableView.backgroundColor = app?.genererValue.colorMostOf
        self.tableView.separatorColor = UIColor.whiteColor()//UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
        cell.backgroundColor = app?.genererValue.colorMostOf
        cell.textLabel?.textColor = UIColor.whiteColor()
        let bgCorlor = UIView()
        bgCorlor.backgroundColor = app?.genererValue.colorMostOf
        cell.selectedBackgroundView = bgCorlor
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.bounds.size.height / 14
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let navi = UINavigationController(rootViewController: app!.viewDict["KYDrawerController"]!)
        app?.window?.rootViewController = navi
        var vc: UIViewController?
        if indexPath.row == 0 {
            app?.flagsScanWifi = nil
            print("scan qrcode")
            vc = app?.viewDict["KYDrawerController"]!.storyboard?.instantiateViewControllerWithIdentifier("xxx")
            app?.window?.rootViewController = vc
        } else if indexPath.row == 1 {
            app!.flagsScanWifi = true
            vc = app?.viewDict["KYDrawerController"]!.storyboard?.instantiateViewControllerWithIdentifier("xxx")
            app?.window?.rootViewController = vc
        } else if indexPath.row == 6 {
            vc = app?.viewDict["KYDrawerController"]!.storyboard?.instantiateViewControllerWithIdentifier("onboardingView")
            app?.window?.rootViewController = vc
        }else {
            app!.viewDict["KYDrawerController"]!.navigationController?.pushViewController({
                if indexPath.row == 2 {
                    print("acount vc")
                    if Defaults["login"].boolValue == true {
                        vc = app!.viewDict["KYDrawerController"]!.storyboard?.instantiateViewControllerWithIdentifier(SEGUE_ACOUNT) as! AcountVC
                    } else {
                        vc = app!.viewDict["KYDrawerController"]!.storyboard?.instantiateViewControllerWithIdentifier(SEGUE_LOGGED_IN) as! LoginVC
                    }
                } else if indexPath.row == 3 {
                    if Defaults["login"].boolValue == false {
                        vc = app!.viewDict["KYDrawerController"]!.storyboard?.instantiateViewControllerWithIdentifier(SEGUE_LOGGED_IN) as! LoginVC
                    } else {
                        APIManager.removeDevice()
                        Defaults[.login] = false
                        KeychainSwift().delete(TOKEN)
                        app?.genererValue._indexFirst = 0
                        app!.countBagde = 0
                        app?.cPageIndex = 0
                        print("log out")
                        app!.listOrder.removeAll()
                        deleteAllOrderBagde()
                        vc = app!.viewDict["KYDrawerController"]!.storyboard?.instantiateViewControllerWithIdentifier(SEGUE_LOGGED_IN) as! LoginVC
                    }
                } else if indexPath.row == 4{
                    if Defaults["login"].boolValue == false {
                        vc = app!.viewDict["KYDrawerController"]!.storyboard?.instantiateViewControllerWithIdentifier(SEGUE_LOGGED_IN) as! LoginVC
                    } else {
                        vc = app?.viewDict["KYDrawerController"]!.storyboard?.instantiateViewControllerWithIdentifier(SEGUE_CHANGEPASS) as! ChangePassVC
                    }
                    
                    app?.flagsChangePassword = true
                    
                } else if indexPath.row == 5 {
                    vc = app?.viewDict["KYDrawerController"]!.storyboard?.instantiateViewControllerWithIdentifier(SEGUE_LANGUAGE) as! Languages
                    
                } else if indexPath.row == 6 {
                    vc = app?.viewDict["KYDrawerController"]!.storyboard?.instantiateViewControllerWithIdentifier("onboardingView")
                }
                return vc!
                }(), animated: false)
        }
        
        (app!.viewDict["KYDrawerController"] as! KYDrawerController).setDrawerState(KYDrawerController.DrawerState.Closed, animated: true)
    }
    
    func deleteAllOrderBagde(){
        let coreData = CoreData()
        let managedContext = coreData.managedObjectContext
        let request = NSFetchRequest(entityName: "Items")
        let sort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sort]
        result = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try result?.performFetch()
        } catch {
            fatalError("Error load data")
        }
        let items: [Items] = result?.fetchedObjects as! [Items]
        guard items.count >= 1  else{
            return
        }
        for i in 0...items.count - 1 {
                items[i].quantity = 0
        }
        do {
             try managedContext.save()
        } catch {
            fatalError("Cant save Items")
        }
       
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Slide
    }
    override func prefersStatusBarHidden() -> Bool {
        return isHidden
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        showStatusBar()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        app?.navitabbar.showNaviTabBar()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = true
        UIApplication.sharedApplication().statusBarHidden = true
    }
}