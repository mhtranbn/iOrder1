//
//  CurrentOrderVC.swift
//  iOrder
//
//  Created by mhtran on 6/5/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit
import CoreData
import Money
import SwiftyJSON
import SwiftString
import Alamofire
import Kingfisher

class CurrentOrderVC: UITableViewController {

    var app: AppDelegate? = nil
    var coreData = CoreData()
    var managedObjectContext: NSManagedObjectContext!
    var dataCurrentOrder : [ListaddOrder] = []
    var cellID = ["#","##","###"]
    var deleteToZero: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        app = UIApplication.sharedApplication().delegate as? AppDelegate
        addRefreshController()
        app!.viewDict["CurrentOrderVC"] = self
        loadData()
        let nibCell1 = UINib(nibName: "CurrentOrderNewBillCell", bundle: nil)
        self.tableView.registerNib(nibCell1, forCellReuseIdentifier: cellID[0])
        let nibCell2 = UINib(nibName: "CurrentOderPayCell", bundle: nil)
        self.tableView.registerNib(nibCell2, forCellReuseIdentifier: cellID[1])
        let nibCell3 = UINib(nibName: "EmptyCellCustom", bundle: nil)
        self.tableView.registerNib(nibCell3, forCellReuseIdentifier: cellID[2])
        self.tableView.allowsSelection = false
    }
    
    func addRefreshController(){
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(CurrentOrderVC.refresh(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func refresh(refreshCtl : UIRefreshControl){
        refreshCtl.endRefreshing()
    }

    deinit {
        print("SecondViewController deinit")
    }

    func reloadTable() {
        loadData()
        self.tableView.reloadData()
    }
    
    func loadData(){
        dataCurrentOrder = app!.listOrder
        if dataCurrentOrder.count > 0 {
            app!.genererValue._total = 0
            for i in 0...(dataCurrentOrder.count - 1) {
                app!.genererValue._total += (dataCurrentOrder[i].price * dataCurrentOrder[i].count)
            }
        }
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataCurrentOrder.count + 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
            let a = indexPath.row
        if dataCurrentOrder.count == 0 {
            self.tableView.separatorStyle = .None
            if let dequecell = tableView.dequeueReusableCellWithIdentifier(cellID[2], forIndexPath: indexPath) as? EmptyCellCustom{
                cell = dequecell
                delay(3, closure: {
                    (self.app!.viewDict["ContainerMyOrderVC"] as! ContainerMyOrderVC).swipeableView.jumpToCurrentOrderView()
                })
            }
        } else {
            if a < dataCurrentOrder.count {
                let data = dataCurrentOrder[a]
                if let dequecell = tableView.dequeueReusableCellWithIdentifier(cellID[0], forIndexPath: indexPath) as? CurrentOrderNewBillCell {
                    dequecell.imageItems.kf_showIndicatorWhenLoading = true
                    dequecell.imageItems.kf_setImageWithURL(NSURL(string: data.image)!, placeholderImage: UIImage(named: "NoImage.png"), optionsInfo: [.Transition(ImageTransition.Fade(1))], progressBlock: { receivedSize, totalSize in
                        print("\(indexPath.row + 1): \(receivedSize)/\(totalSize)")
                        }, completionHandler: { (image, error, cacheType, imageURL) in
                            print("\(indexPath.row + 1): Finished")
                    })
                    dequecell.name.text = data.name
                    dequecell.name.text = data.name
                    dequecell.quantity.text = String(data.count)
                    dequecell.price.text = String(VND(minorUnits: data.price))
                    if data.options == [:] {
                        dequecell.textView.text = data.desription
                    } else {
                        dequecell.textView.text = getNamesOptions(a)
                    }
                    cell = dequecell
                }
            }
            if a == dataCurrentOrder.count  {
                if let dequecell = tableView.dequeueReusableCellWithIdentifier(cellID[1], forIndexPath: indexPath) as? CurrentOderPayCell{
                    dequecell.total.text = String(VND(minorUnits: app!.genererValue.total))
                    app!.genererValue._total = 0
                    dequecell.callBack = {
                        print("OK")
                        if self.sendServer() == true {
                        }
                    }
                    cell = dequecell
                }
            }
        }
        return cell
    }
    
    func getNamesOptions(index: Int) -> String {
        var result: String = " ! - "
        for (key,value) in dataCurrentOrder[index].nameOV {
            if value == "null" || value == "" {
                result += key + "\n - "
            } else {
                result += value + "\n - "
            }
        }
        result = result.between("!", "\n")!
        return result
    }
    
    func sendServer() -> Bool{
        var params2:Dictionary<String,AnyObject>! = Dictionary<String,AnyObject>()
        var params3 = Dictionary<String,AnyObject>()
        var params4 = Dictionary<String,AnyObject>()
        guard app!.listOrder.count >= 1 else {
            return false
        }
        for i in 0...(app!.listOrder.count - 1) {
            var arrKey = [String]()
            var arrValue = [String]()
            var clean:[String: AnyObject] = [:]
            for (_, _) in app!.listOrder[i].options {
                clean = Dictionary(
                    app!.listOrder[i].options.flatMap(){
                        return ($0.1 == "") ? .None : $0
                    })
            }
            if clean.count == 0 {
                params3["table_id"] = "\(app!.genererValue.table_id)"
                params3["item_id"] = "\(app!.listOrder[i].id)"
                params3["quantity"] = "\(app!.listOrder[i].count)"
            } else {
                for (key, value) in clean {
                    arrKey.append("\(key)")
                    arrValue.append("\(value)")
                }
                for j in 0...clean.count - 1{
                    params4["options\(j + 1)"] = ["value_id":"\(arrValue[j])",
                                                  "option_id":"\(arrKey[j])"
                    ]
                    params3["options"] = params4
                    
                }
                params4.removeAll()
                params3["table_id"] = "\(app!.genererValue.table_id)"
                params3["item_id"] = "\(app!.listOrder[i].id)"
                params3["quantity"] = "\(app!.listOrder[i].count)"
                clean.removeAll()
                arrKey.removeAll()
                arrValue.removeAll()
            }
            params2["orders\(i)"] = params3
            params3.removeAll()
        }
        let params = [
            "orders": params2
        ]
        APIManager.orderItemList(params)
        return true
    }
    
    func afterOrderList(json:JSON) {
            guard json["status_code"].rawString()! == "null" else {
                var error: String = ""
                for (_,subJson):(String,JSON) in (json["errors"].dictionary)! {
                    error = subJson[0].string!
                }
                self.showAlert("Error".localized(), message: "\(error)")
                self.view.endEditing(true)
                return
            }
            if json["message"] != nil {
                self.app!.listOrder.removeAll()
                removeAllBagde()
                (self.app!.viewDict["ContainerMyOrderVC"] as! ContainerMyOrderVC).swipeableView.jumpToCurrentOrderView()
                
            } else {
                
            }
    }
    
    func removeAllBagde() {
        let tabItem = self.tabBarController!.tabBar.items![2]
        tabItem.badgeValue = nil
        app!.countBagde = 0
        let animationItem : RAMAnimatedTabBarItem = self.tabBarController!.tabBar.items![2] as! RAMAnimatedTabBarItem
        animationItem.playAnimation()
    }
    
    func removeOneBagde() {
        let tabItem = self.tabBarController!.tabBar.items![2]
        tabItem.badgeValue = nil
        if app?.countBagde > 0 {
            tabItem.badgeValue = "\(app!.countBagde)"
        }
        let animationItem : RAMAnimatedTabBarItem = self.tabBarController!.tabBar.items![2] as! RAMAnimatedTabBarItem
        animationItem.playAnimation()
    }
    
    func showAlert(title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let actionOK = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler:{ (UIAlertAction) in
            
        })
        alertView.addAction(actionOK)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if app!.cellLockSwipe == false && indexPath.row != dataCurrentOrder.count {
            return UITableViewCellEditingStyle.Delete
        } else {
            return UITableViewCellEditingStyle.None
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let indexPaths = [indexPath]
        tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
    }
    
    override func tableView(tableView: UITableView,
                   editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let tg = self.dataCurrentOrder[indexPath.row]
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "CANCEL".localized()){(UITableViewRowAction,NSIndexPath) -> Void in
            self.app!.genererValue._total -= tg.price * tg.count
            self.dataCurrentOrder.removeAtIndex(indexPath.row)
            self.app!.countBagde -= 1
            self.app!.listOrder = self.dataCurrentOrder
            if self.app?.dataOrder.count == 0 {
                self.deleteToZero = true
            }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:.Fade)
            self.removeOneBagde()
            print("Your action when user pressed delete")
            self.reloadTable()
        }
        delete.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        return [delete]
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("indexpath.row = \(indexPath.row)")
        
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 60))
        footerView.backgroundColor = UIColor.clearColor()
        return footerView
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let a = indexPath.row
        if dataCurrentOrder.count == 0 {
            return 136
        }
        if  a < dataCurrentOrder.count {        
            return 136
        } else if a == dataCurrentOrder.count  {
            return 290
        }
        return 136
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        showMenuBar()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func showMenuBar(){
        self.tabBarController?.tabBar.hidden = true
        app!.navitabbar.showNaviTabBar()
    }
}
