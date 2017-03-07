//
//  MenuVC.swift
//  iOrder
//
//  Created by mhtran on 5/2/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import AlamofireImage
import Money
import SwiftyJSON
import Kingfisher

class MenuVC: UITableViewController,NSFetchedResultsControllerDelegate, NVActivityIndicatorViewable{
    
    var catergoryId: String! = ""
    var managedObjectContext : NSManagedObjectContext!
    var items : [Items] = []
    var categorys: [Categorys] = []
    var restaurant: [Restaurants] = []
    var currentPage: Int = 1
    var app:AppDelegate!
    var result: NSFetchedResultsController!
    let transition = Animator()
    var selectedImage: UIGradientImageView?
    var cellID:[String] = ["$"]
    override func viewDidLoad() {
        super.viewDidLoad()
        let coreData = CoreData()
        managedObjectContext = coreData.managedObjectContext
        app = UIApplication.sharedApplication().delegate as! AppDelegate
        addRefreshController()
        self.app?.viewDict["MenuVC"] = self
        loadData()
        items = result.fetchedObjects as! [Items]
        self.edgesForExtendedLayout = .None
        let nibName = UINib(nibName: "EmptyCellCustom", bundle: nil)
        self.tableView.registerNib(nibName, forCellReuseIdentifier: cellID[0])
    }
    
    func checkBagde(){
        if app.flagBadgeAnimate == true {
            app.flagBadgeAnimate = false
             self.app.countBagde += 1
        }
        if app?.countBagde > 0 {
            let tabItem = self.tabBarController?.tabBar.items![2]
            tabItem!.badgeValue = nil
            let animationItem : RAMAnimatedTabBarItem = self.tabBarController!.tabBar.items![2] as! RAMAnimatedTabBarItem
            delay(1, closure: {
                tabItem!.badgeValue = "\(self.app!.countBagde)"
                animationItem.playAnimation()
            })
            
        }
    }
    
    func addRefreshController(){
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MenuVC.refresh(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func refresh(refreshCtl : UIRefreshControl){
        refreshCtl.endRefreshing()
    }
    
    deinit {
        print("MenuVC deinit")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        app?.navitabbar.showNaviTabBar()
        checkBagde()
        if app.flagsSearchVC == true {
           self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        transition.dismissCompletion = {
            self.selectedImage!.hidden = false
        }
    }
    
    func loadData() {
        let request = NSFetchRequest(entityName:"Items")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = NSPredicate(format: "category_id = %@", catergoryId)
        result = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try result.performFetch()
        } catch {
            fatalError("error get data Items")
        }
    }
    
    func getThumbFirstInArray(index: Int) -> NSURL{
        let a = NSURL(string:(JSON(data: items[index].thumbs! as NSData).array)![0].rawString()!)
        return a!
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 59.9
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 60))
        footerView.backgroundColor = UIColor.clearColor()
        return footerView
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var totalCount: Int = 1
        if items.count == 0 {
        } else {
            totalCount = items.count
        }
        return totalCount
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier:String = "ItemsCustomCellTableViewCell"
        let index = indexPath.row
        var cell: UITableViewCell!
        if items.count == 0 {
            if let dequecell:EmptyCellCustom = self.tableView.dequeueReusableCellWithIdentifier(cellID[0], forIndexPath: indexPath) as? EmptyCellCustom {
                dequecell.emptyLabel.text = "Opps! it will comming soon!".localized()
                cell = dequecell
            }
        } else {
            if let dequcell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? ItemsCustomCellTableViewCell {
                dequcell.itemsImage.kf_showIndicatorWhenLoading = true
                dequcell.itemsImage.kf_setImageWithURL(getThumbFirstInArray(index), placeholderImage: UIImage(named: "NoImage.png"),
                                                       optionsInfo: [.Transition(ImageTransition.Fade(1))],
                                                       progressBlock: { receivedSize, totalSize in
                                                        print("\(index + 1): \(receivedSize)/\(totalSize)")
                    },
                                                       completionHandler: { image, error, cacheType, imageURL in
                                                        print("\(index + 1): Finished")
                })
                dequcell.itemsName.text = items[index].name
                dequcell.itemsPrice.text = String(VND(minorUnits: Int(items[index].price!)))
                NSLog("-------log here \(NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate: NSDate()).minute) please see it----= \(items[index].rate!)")
                dequcell.countVote.text = String(Float(items[index].rate!))
                /*dequcell.showBagde(Int(self.items[index].quantity!))*/
                /*if index == app.numberOfBagde {
                    app.numberOfBagde = 9999
                    dequcell.flagCallback = true
                }*/
                /*dequcell.callBack = {
                 print("Meu chek")
                 //check Login
                 if Defaults["login"].boolValue == false {
                 /*self.app.numberOfBagde = index*/
                 let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                 let mainPage: LoginVC = mainStoryboard.instantiateViewControllerWithIdentifier(SEGUE_LOGGED_IN) as! LoginVC
                 self.app.flagJumpToMenuVC = true
                 let mainPageNavi = UINavigationController(rootViewController: mainPage)
                 self.app.window?.rootViewController = mainPageNavi
                 } else {
                 
                 let alertView = UIAlertController(title: "Confirm!".localized(), message: "Order Now".localized(), preferredStyle: UIAlertControllerStyle.Alert)
                 let actionOK = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler:{ (UIAlertAction) in
                 self.items[index].quantity! = NSNumber(int: 1 + Int(self.items[index].quantity!))
                 try! self.managedObjectContext.save()
                 /*dequcell.showBagde(Int(self.items[index].quantity!))*/
                 delay(2, closure: {
                 let animationItem : RAMAnimatedTabBarItem = self.tabBarController!.tabBar.items![2] as! RAMAnimatedTabBarItem
                 animationItem.playAnimation()
                 })
                 APIManager.orderItem([
                 "table_id" : "\((self.app?.genererValue.table_id)!)",
                 "item_id" : "\(self.items[index].id!)",
                 "quantity" : "1"
                 ])
                 
                 })
                 let cancelAction = UIAlertAction(title: "CANCEL".localized(), style: UIAlertActionStyle.Default, handler: nil)
                 alertView.addAction(actionOK)
                 alertView.addAction(cancelAction)
                 self.presentViewController(alertView, animated: true, completion: nil)
                 }
                 }*/
                cell = dequcell
            }
        }
        return cell
    }
    
    func showAlert(title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let actionOK = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler:{ (UIAlertAction) in
            
        })
        alertView.addAction(actionOK)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.row
        if JSON(data: items[index].option! as NSData).array!.count == 0 {
                print("Meu chek")
                //check Login
                if Defaults["login"].boolValue == false {
                    /*self.app.numberOfBagde = index*/
                    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let mainPage: LoginVC = mainStoryboard.instantiateViewControllerWithIdentifier(SEGUE_LOGGED_IN) as! LoginVC
                    self.app.flagJumpToMenuVC = true
                    let mainPageNavi = UINavigationController(rootViewController: mainPage)
                    self.app.window?.rootViewController = mainPageNavi
                } else {
                    
                    let alertView = UIAlertController(title: "Confirm!".localized(), message: "Order Now".localized(), preferredStyle: UIAlertControllerStyle.Alert)
                    let actionOK = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler:{ (UIAlertAction) in
                        self.items[index].quantity! = NSNumber(int: 1 + Int(self.items[index].quantity!))
                        try! self.managedObjectContext.save()
                        /*dequcell.showBagde(Int(self.items[index].quantity!))*/
                        delay(2, closure: {
                            let animationItem : RAMAnimatedTabBarItem = self.tabBarController!.tabBar.items![2] as! RAMAnimatedTabBarItem
                            animationItem.playAnimation()
                        })
                        APIManager.orderItem([
                            "table_id" : "\((self.app?.genererValue.table_id)!)",
                            "item_id" : "\(self.items[index].id!)",
                            "quantity" : "1"
                            ])
                        
                    })
                    let cancelAction = UIAlertAction(title: "CANCEL".localized(), style: UIAlertActionStyle.Default, handler: nil)
                    alertView.addAction(actionOK)
                    alertView.addAction(cancelAction)
                    self.presentViewController(alertView, animated: true, completion: nil)
                }
        } else {
            selectedImage = (self.tableView.cellForRowAtIndexPath(indexPath)! as! ItemsCustomCellTableViewCell).itemsImage
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier(SEGUE_DETAILITEMSVC) as! DetailItemVC
            vc.transitioningDelegate = self
            vc.setDataItems(index, catergoryID: items[index].category_id!)
            presentViewController(vc, animated: true, completion: nil)
            app.navitabbar.hideNaviBarTabbar()
        }
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition({context in
            }, completion: nil)
    }
}

//extension
extension SearchVC: UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.originFrame = selectedImage!.convertRect(CGRectMake(0, 0, 1, 1), toView: nil)
        transition.presenting = true
        selectedImage!.hidden = true
        return transition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        return transition
    }
}