//
//  NewBillVC.swift
//  iOrder
//
//  Created by mhtran on 6/7/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData
import Money

class NewBillVC: UITableViewController,NSFetchedResultsControllerDelegate {
    var app : AppDelegate? = nil
//    var callBack: (()-> Void)?
    var billKindOf: String? = "single"
    var result : NSFetchedResultsController!
    var cellID = ["#","##","$","$$","#$"]
    var countCell: Int = 0
    var listIdOrder :[String] = []
    let keychain = KeychainSwift()
    var task: dispatch_cancelable_closure?
    var task2 : dispatch_cancelable_closure?
    override func viewDidLoad() {
        super.viewDidLoad()
        app = UIApplication.sharedApplication().delegate as? AppDelegate
        getDataNewBill(billKindOf!)
        let nibCell1 = UINib(nibName: "DetailHistoryCell1", bundle: nil)
        self.tableView.registerNib(nibCell1, forCellReuseIdentifier: cellID[0])
        let nibCell2 = UINib(nibName: "DetailHistoryCell2", bundle: nil)
        self.tableView.registerNib(nibCell2, forCellReuseIdentifier: cellID[1])
        let nibCell3 = UINib(nibName: "NewBillCell3", bundle: nil)
        self.tableView.registerNib(nibCell3, forCellReuseIdentifier: cellID[2])
        let nibCell4 = UINib(nibName: "QuantityNamePriceCell", bundle: nil)
        self.tableView.registerNib(nibCell4, forCellReuseIdentifier: cellID[3])
        let nibCell5 = UINib(nibName: "EmptyCellCustom", bundle: nil)
        self.tableView.registerNib(nibCell5, forCellReuseIdentifier: cellID[4])
        self.tableView.rowHeight = 236
        self.tableView.allowsSelection = false
        app?.viewDict["NewBillVC"] = self
        (app!.viewDict["KYDrawerController"] as! KYDrawerController).naviCustom.hidden = false
    }
    
    func reloadTable() {
        getDataNewBill(billKindOf!)
        self.tableView.reloadData()
    }
    
    func getDataNewBill(kindOf: String) {
        
        if  kindOf == "single" {
            APIManager.getBill()
            
        } else if kindOf == "group" {
            APIManager.getAllbill()
            
        }

    }
    
    func saveData(json: JSON, kindOf:String) {
        let coreData = CoreData()
        let managedObjectContext = coreData.managedObjectContext
        self.deleteData()
        let newbill = NSEntityDescription.insertNewObjectForEntityForName("NewBill", inManagedObjectContext: managedObjectContext) as! NewBill
        if (json["restaurant"].rawString() != "null") {
            do{
                newbill.restaurant = try json["restaurant"].rawData()
            } catch {
                print("Error with get bills")
            }
        }
        if (json["orders"].rawString() != "null") {
            
            do{
                
                newbill.orders = try json["orders"].rawData()
            } catch {
                print("Error with get orders")
            }
        }
        if (json["sub_total"].rawString() != "null") {
            newbill.kindOf = kindOf
            newbill.sub_total = json["sub_total"].double!
        }
        
        if (json["tax"].rawString() != "null") {
            newbill.tax = json["tax"].double!
        }
        
        if (json["total"].rawString() != "null") {
            newbill.total = json["total"].double!
        }
        coreData.saveContext()
        let error: NSErrorPointer = nil
        let request = NSFetchRequest(entityName: "NewBill")
        let newBillCount = managedObjectContext.countForFetchRequest(request, error: error)
        if newBillCount > 0 {
            self.loadData(self.billKindOf!)
            self.result.delegate = self
            self.tableView.reloadData()
        } else {
            
        }
        
    }


    func loadData(kindOf: String){
        listIdOrder.removeAll()
        let coreData = CoreData()
        let managedObjectContext = coreData.managedObjectContext
        let request = NSFetchRequest(entityName: "NewBill")
        request
        let sort = NSSortDescriptor(key: "kindOf", ascending: true)
        request.sortDescriptors = [sort]
        result = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try result.performFetch()
        } catch {
            fatalError("Error in fetching records")
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard result != nil else {
            countCell = 1
            return countCell
        }
        if (result.fetchedObjects as! [NewBill]).count > 0 {
            if (result.fetchedObjects as! [NewBill])[0].orders == nil {
                countCell = 1
                return countCell
            } else {
                countCell = (JSON(data: (result.fetchedObjects as! [NewBill])[0].orders as! NSData)).count + 3
            }
        } else {
            countCell = 3
        }
        return countCell
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        let index = indexPath.row
        guard result != nil else {
            if index == 0 {
                if let dequecell = self.tableView.dequeueReusableCellWithIdentifier(cellID[4], forIndexPath: indexPath) as? EmptyCellCustom {
                    self.tableView.separatorStyle = .None
                    cell = dequecell
                    task = delay(4, closure: {
                        (self.app!.viewDict["ContainerBillVC"] as! ContainerBillVC).swipeableView.jumpToCurrentOrderView()
                        print("History now")
                    })
                }
            }
            return cell
        }
        let dataResult = result.fetchedObjects as! [NewBill]
        if dataResult.count > 0 && result.fetchedObjects![0].orders == nil {
            if index == 0 {
                if let dequecell = self.tableView.dequeueReusableCellWithIdentifier(cellID[4], forIndexPath: indexPath) as? EmptyCellCustom {
                    self.tableView.separatorStyle = .None
                    cell = dequecell
                    task2 = delay(4, closure: {
                        (self.app!.viewDict["ContainerBillVC"] as! ContainerBillVC).swipeableView.jumpToCurrentOrderView()
                        print("History now")
                    })
                }
            }
            return cell
        }
        if dataResult.count > 0 && dataResult[0].orders != nil{
            if index == 0 {
                if let dequecell = self.tableView.dequeueReusableCellWithIdentifier(cellID[0], forIndexPath: indexPath) as? DetailHistoryCell1 {
                    cancel_delay(self.task)
                    cancel_delay(self.task2)
                    let a = JSON(data: dataResult[0].restaurant as! NSData)[0].dictionary!
                    for (_,_):(String,JSON) in a {
                        if a["name"]!.rawString()! != "null" {
                            dequecell.name.text = a["name"]!.rawString()!.uppercaseString
                        }
                        
                        if a["address"]!.rawString()! != "null" {
                            dequecell.address.text = a["address"]!.rawString()!
                        }
                        
                        if a["website"]!.rawString()! != "null" {
                            dequecell.website.text = a["website"]!.rawString()!
                        }
                        
                        if a["phone"]!.rawString()! != "null" {
                            dequecell.phone.text = a["phone"]!.rawString()!
                        }
                        cell = dequecell
                    }
                }
            } else if index == 1 {
                if let dequecell = self.tableView.dequeueReusableCellWithIdentifier(cellID[3], forIndexPath: indexPath) as? QuantityNamePriceCell {
                    cell = dequecell
                }
            } else if index >= 2 && index < (countCell - 1) {
                if let dequecell = self.tableView.dequeueReusableCellWithIdentifier(cellID[1], forIndexPath: indexPath) as? DetailHistoryCell2 {
                    let c = JSON(data: dataResult[0].orders! as! NSData)
                    let d = c[index - 2].dictionary
                    if d!["quantity"]!.rawString()! != "null" {
                        dequecell.quantity.text = d!["quantity"]!.rawString()!
                    }
                    if d!["id"]!.rawString()! != "null" {
                        listIdOrder.append(d!["id"]!.rawString()!)
                    }
                    
                    if d!["name"]!.rawString()! != "null" {
                        dequecell.name.text = d!["name"]!.rawString()!
                    }
                    if d!["price"]!.rawString()! != "null" {
                        dequecell.price.text = String(VND(minorUnits: d!["price"]!.int!))
                    }
                    
                    cell = dequecell
                }
            } else if index == (countCell - 1) {
                if let dequecell = self.tableView.dequeueReusableCellWithIdentifier(cellID[2], forIndexPath: indexPath) as? NewBillCell3{
                    
                    dequecell.subTotal.text = String(VND(minorUnits: Int((dataResult)[0].sub_total!)))
                    dequecell.tax.text = String(VND(minorUnits: Int((dataResult)[0].tax!)))
                    dequecell.total.text = String(VND(minorUnits: Int(dataResult[0].total!)))
                    dequecell.callBack = {
                        print("aksdhfkjsdhfksdj")
                        if dequecell.checkBox.checked == true {
                            self.deleteData()
                            self.billKindOf = "group"
                            self.getDataNewBill(self.billKindOf!)
                            dequecell.checkBox.hardcodeCheck(false)
                        } else {
                            self.deleteData()
                            self.billKindOf = "single"
                            self.getDataNewBill(self.billKindOf!)
                        }
                    }
                    dequecell.callBackPay = {
                        print("kjahdkjsahdkasjhdjksadhsajkd")
                        self.sendListIDToSerVer()
                    }
                    cell = dequecell
                }
                
            }
        } else {
            if index == 0 {
                if index == 0 {
                    if let dequecell = self.tableView.dequeueReusableCellWithIdentifier(cellID[4], forIndexPath: indexPath) as? EmptyCellCustom {
                        self.tableView.separatorStyle = .None
                        cell = dequecell
                    }
                }
                return cell

            } else if index == 1 {
                let dequecell = self.tableView.dequeueReusableCellWithIdentifier(cellID[3], forIndexPath: indexPath) as? QuantityNamePriceCell
                cell = dequecell
            }else if index == 2 {
                let dequecell = self.tableView.dequeueReusableCellWithIdentifier(cellID[2], forIndexPath: indexPath) as? NewBillCell3
                
                dequecell!.subTotal.text = ""
                dequecell!.tax.text = ""
                dequecell!.total.text = ""
                cell = dequecell
            }  
            return cell
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 60))
        footerView.backgroundColor = UIColor.clearColor()
        return footerView
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let a = indexPath.row
        if countCell == 1 {
            return 136
        } else {
            
        }
        if a == 0 {
            
            return 200
        } else if a >= 2 && a < (countCell - 1) {
            
            return 40
        } else if a == (countCell - 1) {
            
            return 340
        }
        
        return 40

    }
    
    func deleteData(){
        do {
            let coreData = CoreData()
            let managedObjectContext = coreData.managedObjectContext
            let coord = coreData.persistentStoreCoordinator
            let fetchResquest = NSFetchRequest(entityName: "NewBill")
            if #available(iOS 9.0, *) {
                let deleteResquest = NSBatchDeleteRequest(fetchRequest: fetchResquest)
                do {
                    try coord.executeRequest(deleteResquest, withContext: managedObjectContext)
                    
                } catch let error as NSError {
                    fatalError("error delete bill \(error.debugDescription)")
                }

            } else {
                // Fallback on earlier versions
                do {
                   coreData.deleteCoreData(fetchResquest)
                }
            }
            
        }
    }
    
    func sendListIDToSerVer() -> Bool{
        guard countCell >= 4 else {
            return false
        }

        APIManager.createNewBill(listIdOrder, callBackBill:{
            (index: Int , json: JSON) -> Void in
            if index == 0 {
                if json["bill"]["status"] == "unpaid" {
                    self.app!.listOrder.removeAll()
                    self.navigationController?.pushViewController({
                        let vc = self.storyboard?.instantiateViewControllerWithIdentifier(SEGUE_PAY_VC) as! PayVC
                        vc.billId = json["bill"]["id"].rawString()!
                        return vc
                        }(), animated: false)
                }else {
                    print("Cant send")
                    // show alertView
                    self.showAlert("Error", message: "Cant send")
                }
            }else if index == 1 {
               print("Nothing")
                self.showAlert("Opps!", message: "Opps")
            }else if index == 2 {
                self.showAlert("Error", message: "Network error, Please check network")
            }
            print("Error")
        })
        return false
    }
    
    func showAlert(title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let actionOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction) in
            
        })
        alertView.addAction(actionOK)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        app?.navitabbar.showNaviTabBar()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        task = nil
        task2 = nil
    }
}
