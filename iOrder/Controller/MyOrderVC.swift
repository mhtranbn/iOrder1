//
//  MyOrderVC.swift
//  iOrder
//
//  Created by mhtran on 5/2/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON
import CoreData
import Money
import Kingfisher
import SwiftString


class MyOrderVC: UITableViewController, NSFetchedResultsControllerDelegate  {
    
    var app : AppDelegate? = nil
    var managedObjectContext : NSManagedObjectContext!
    var result,result2: NSFetchedResultsController!
    var userId: String = ""
    var countCell :Int = 0
    var cellID: [String] = ["#","##"]
    var deleteToZero : Bool = false
    //    var flags: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        app = UIApplication.sharedApplication().delegate as? AppDelegate
        addRefreshController()
        self.app?.dataOrder.removeAll()
        app!.viewDict["MyOrderVC"] = self
        let coreData = CoreData()
        managedObjectContext = coreData.managedObjectContext
        APIManager.getOrderItems()
        let nibCell = UINib(nibName: "MyOrderCustomCell", bundle: nil)
        self.tableView.registerNib(nibCell, forCellReuseIdentifier: cellID[0])
        let nibCell2 = UINib(nibName: "EmptyCellCustom", bundle: nil)
        self.tableView.registerNib(nibCell2, forCellReuseIdentifier: cellID[1])
        self.tableView.allowsSelection = false
    }
    
    func addRefreshController(){
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MyOrderVC.refresh(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func refresh(refreshCtl : UIRefreshControl){
        refreshCtl.endRefreshing()
    }
    
    func reload() {
        APIManager.getOrderItems()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        app?.navitabbar.showNaviTabBar()
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        app!.dataOrder.count == 0
        return 136
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
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
        guard app!.dataOrder.count > 0 else {
            self.tableView.separatorStyle = .None
            countCell = 1
            if self.deleteToZero == true {
                deleteToZero = false
                countCell = 0
            }
            return countCell
        }
        self.tableView.separatorStyle = .SingleLine
        countCell = app!.dataOrder.count
        return countCell
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        var cell : UITableViewCell!
        
        if app!.dataOrder.count == 0 {
            if let dequecell = tableView.dequeueReusableCellWithIdentifier(cellID[1], forIndexPath: indexPath) as? EmptyCellCustom{
                cell = dequecell
            }
        } else {
            
            if let dequecell = self.tableView.dequeueReusableCellWithIdentifier(cellID[0],forIndexPath: indexPath) as? MyOrderCustomCell {
                
                dequecell.imageItems.kf_showIndicatorWhenLoading = true
                dequecell.imageItems.kf_setImageWithURL(getThumbFirstInArray(index), placeholderImage: UIImage(named: "NoImage.png"), optionsInfo: [.Transition(ImageTransition.Fade(1))], progressBlock: { receivedSize, totalSize in
                    print("\(indexPath.row + 1): \(receivedSize)/\(totalSize)")
                    }, completionHandler: { (image, error, cacheType, imageURL) in
                        print("\(indexPath.row + 1): Finished")
                })
                _ = (JSON(data:app!.dataOrder[index].item! as NSData).dictionary)!["name"]?.rawString()!
                dequecell.name.text = (JSON(data:app!.dataOrder[index].item! as NSData).dictionary)!["name"]?.rawString()!
                dequecell.price.text = String(VND(minorUnits: Int(app!.dataOrder[index].price!)))
                dequecell.count.text = String(app!.dataOrder[index].quantity!)
                
                //show option detail on scrollView
                dequecell.textView.text = getNameOptionValue(index)
                dequecell.textView.selectable = false
                
                if (app!.dataOrder[index].status == "new") {
                    
                    dequecell.status.text = "Waiting to cook...".localized()
                }
                if (app!.dataOrder[index].status == "progress") {
                    
                    dequecell.status.text = "Cooking...".localized()
                    
                }
                if (app!.dataOrder[index].status == "served") {
                    
                    dequecell.status.text = "Served".localized()
                }
                
                cell = dequecell
            }
        }
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if app!.cellLockSwipe == false && app!.dataOrder[indexPath.row].status == "new"{
            return UITableViewCellEditingStyle.Delete
        } else {
            return UITableViewCellEditingStyle.None
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let indexPaths = [indexPath]
        tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "CANCEL".localized()) { (UITableViewRowAction, NSIndexPath) -> Void in
            tableView.beginUpdates()
            self.deleteItemsOrder(self.app!.dataOrder[indexPath.row].id!)
            self.app!.dataOrder.removeAtIndex(indexPath.row)
            if self.app?.dataOrder.count == 0 {
                self.deleteToZero = true
            }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.endUpdates()
//            self.tableView.reloadData()
        }
        delete.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        return [delete]
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func getThumbFirstInArray(index: Int) -> NSURL{
        let a = ((JSON(data: app!.dataOrder[index].item!).dictionary)!["thumbs"])?[0].rawString()
        return NSURL(string: a!)!
    }
    
    func deleteItemsOrder(id:String) {
        let keychain = KeychainSwift()
        let token = keychain.get(TOKEN)!
        print("token = \(token)")
        let API_DELETE_AN_ORDER = "\(APIManager.baseURLString)orders/%@?token=\(token)"
        let url = NSString(format: API_DELETE_AN_ORDER, id,token)
        Alamofire.request(.DELETE, "\(url)").responseJSON { (response) in
            let value = response.result.value
            print("json = \(JSON(value!))")
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 59
    }
    
    func showAlert(title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let actionOK = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler:{ (UIAlertAction) in
            
        })
        alertView.addAction(actionOK)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    func saveData(json:JSON) {
        self.deleteData()
        if json["status_code"] != nil || json["orders"] == nil {
            if json["errors"] != nil {
                var error: String = ""
                for (_,subJson):(String,JSON) in (json["errors"].dictionary)! {
                    error = subJson[0].string!
                }
                self.showAlert("Error".localized(), message: "\(error)")
                self.view.endEditing(true)
                
            }
        } else {
            let coreData = CoreData()
            self.managedObjectContext = coreData.managedObjectContext
            guard json["orders"].array?.count > 0 else {
                return
            }
            if let ordersJson: [JSON] = json["orders"].array where json["orders"] != nil{
                
                for i in 0...(ordersJson.count - 1) {
                    let order = NSEntityDescription.insertNewObjectForEntityForName("Order", inManagedObjectContext:self.managedObjectContext) as! Order
                    let a = ordersJson[i]
                    order.id = a["id"].rawString()!
                    _ = a["options"].rawString()!
                    if a["options"].rawString() != "null" {
                        do {
                            try order.options = a["options"].rawData()
                        } catch {
                            fatalError("error get options")
                        }
                    }
                    order.table_id = a["table_id"].rawString()!
                    order.item_id = a["item_id"].rawString()!
                    do {
                        try order.item = (a["item"] as JSON).rawData()
                    } catch {
                        fatalError("error get item")
                    }
                    
                    order.user_id = a["user_id"].rawString()!
                    order.date = a["date"].rawString()!
                    order.price = a["price"].number!
                    order.quantity = a["quantity"].number!
                    do {
                        try order.table = a["table"].rawData()
                    } catch {
                        fatalError("error get table")
                    }
                    do {
                        try order.user = a["user"].rawData()
                    } catch {
                        fatalError("error get user")
                    }
                    order.status = a["status"].rawString()!
                }
                coreData.saveContext()
                let error: NSErrorPointer = nil
                let request = NSFetchRequest(entityName: "Order")
                let orderCount = coreData.managedObjectContext.countForFetchRequest(request, error: error)
                print("Total order is\(orderCount)")
                if orderCount > 0 && json["status_code"] == nil{
                    self.loadData()
                    let app = UIApplication.sharedApplication().delegate as! AppDelegate
                    app.dataOrder = self.result.fetchedObjects as! [Order]
                    self.tableView.reloadData()
                }
            } else {
                // Animation
            }
        }
    }

    func getDescriptionItem(index: Int) -> String{
        let json = JSON(data: app!.dataOrder[index].item!)
        return json["description"].string!
    }
    
    func getNameOptionValue(index: Int) -> String {
        let json = JSON(data:app!.dataOrder[index].options!)
        
        var result: String = " ! - "
        if json.count >= 1 {
            for i in 0...json.count - 1 {
                
                if json[i].dictionary!["value_name"]!.rawString() != "null" {
                    result += json[i].dictionary!["value_name"]!.rawString()!.capitalize() + "\n - "
                } else if json[i].dictionary!["option_name"]?.rawString() != "null"{
                    result += json[i].dictionary!["option_name"]!.rawString()! + "\n - "
                }
                
            }
            result = result.between("!", "\n")!
        } else {
            result = getDescriptionItem(index)
        }
        return result
    }
    
    func loadData(){
        let coreData = CoreData()
        let manaObjectContext = coreData.managedObjectContext
        let request = NSFetchRequest(entityName: "Order")
        let sort = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sort]
        result = NSFetchedResultsController(fetchRequest: request, managedObjectContext: manaObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try result.performFetch()
        } catch {
            fatalError("Error fetch record")
        }
    }
    
    func deleteData(){
        do {
            let coreData = CoreData()
            managedObjectContext = coreData.managedObjectContext
            let coord = coreData.persistentStoreCoordinator
            let fetchResquest = NSFetchRequest(entityName: "Order")
            if #available(iOS 9.0, *) {
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchResquest)
                do {
                    try coord.executeRequest(deleteRequest, withContext: managedObjectContext)
                } catch let error as NSError {
                    fatalError("Cant delete data \(error.debugDescription)")
                }
            } else {
                // Fallback on earlier versions
                do {
                    coreData.deleteCoreData(fetchResquest)
                }

            }

        }
    }
}
