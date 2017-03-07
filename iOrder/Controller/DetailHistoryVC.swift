//
//  DetailHistoryVC.swift
//  iOrder
//
//  Created by mhtran on 6/7/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import AlamofireImage
import CoreData
import Money

class DetailHistoryVC: UIViewController, UITableViewDataSource, UITableViewDelegate,NSFetchedResultsControllerDelegate {

    var app : AppDelegate? = nil
    var bill_id: String?
    @IBOutlet weak var naviCustom: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    var countDtailHistory: Int!
    var detailHistoryData: [DetailHistory] = []
    var result: NSFetchedResultsController!
    var cellID = ["#","##","###","$$","$$$"]
    var countCell: Int! = 0
    let keychain = KeychainSwift()
    @IBOutlet weak var detaiTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        app = UIApplication.sharedApplication().delegate as? AppDelegate
        detaiTitleLabel.text = "Detail History".localized()
        app?.viewDict["DetailHistoryVC"] = self
        naviCustom.backgroundColor = app?.genererValue.color
        backButton.setImage(
            UIImage(named: "arrow.png"),
            inFrame: CGRectMake(backButton.center.x - 9, backButton.center.y - 5, 18, 18),
            forState: UIControlState.Normal
        )
        //MARK: check network
        let nibCell1 = UINib(nibName: "DetailHistoryCell1", bundle: nil)
        self.tableView.registerNib(nibCell1, forCellReuseIdentifier: cellID[0])
        let nibCell2 = UINib(nibName: "DetailHistoryCell2", bundle: nil)
        self.tableView.registerNib(nibCell2, forCellReuseIdentifier: cellID[1])
        let nibCell3 = UINib(nibName: "DetailHistoryCell3", bundle: nil)
        self.tableView.registerNib(nibCell3, forCellReuseIdentifier: cellID[2])
        let nibCell4 = UINib(nibName: "QuantityNamePriceCell", bundle: nil)
        self.tableView.registerNib(nibCell4, forCellReuseIdentifier: cellID[3])
        let nibCell5 = UINib(nibName: "EmptyCellCustom", bundle: nil)
        self.tableView.registerNib(nibCell5, forCellReuseIdentifier: cellID[4])
        
        APIManager.getDetailHistory(bill_id!)
        self.loadData()
        self.result.delegate = self
        detailHistoryData = self.result.fetchedObjects as! [DetailHistory]
        self.tableView.allowsSelection = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        app?.navitabbar.hideNaviBarTabbar()
    }
    
    func saveData(jsons:JSON) {
        deleteData()
        let json1 = jsons.dictionary!
        guard json1["status_code"]?.rawString()! != "500" else {
            self.showAlert("Fail".localized(), message: "Sorry Problem, Please try again.")
            return
        }
        let coreData = CoreData()
        let managedObjectContext = coreData.managedObjectContext
        let detailHistory = NSEntityDescription.insertNewObjectForEntityForName("DetailHistory", inManagedObjectContext:managedObjectContext) as! DetailHistory
        detailHistory.bill_id = bill_id
        let json = json1["bill"]!
        if json["id"] != "null" {
            detailHistory.id = json["id"].rawString()!
        }
        
        if json["date"] != "null" {
            detailHistory.date = json["date"].rawString()!
        }
        
        if json["status"].rawString() != "null" {
            
            detailHistory.status = json["status"].rawString()!
        }
        
        if json["total"].rawString()! != "null" {
            
            detailHistory.total = json["total"].double!
        }
        
        if json["tax"].rawString()! != "null" {
            
            detailHistory.tax = json["tax"].double!
        }
        
        if json["sub_total"].rawString()! != "null" {
            
            detailHistory.subTotalDetal = json["sub_total"].double!
        }

        if json["orders"].rawString()! != "null" {
            
            do {
                try detailHistory.orders = json["orders"].rawData()
            } catch {
                print("error oredr")
            }
        }
        
        if json["user"].rawString()! != "null" {
            do {
                try detailHistory.user = json["user"].rawData()
            } catch {
                print("error ueser")
            }
        }
        
        if json["restaurant"].rawString()! != "null" {
            do {
                try detailHistory.restaurant = json["restaurant"].rawData()
            } catch {
                print("error restaurant")
            }
        }
        coreData.saveContext()
        let requestDetail = NSFetchRequest(entityName: "DetailHistory")
        let sort = NSSortDescriptor(key: "bill_id", ascending: true)
        requestDetail.sortDescriptors = [sort]
        let error: NSErrorPointer = nil
        self.countDtailHistory = managedObjectContext.countForFetchRequest(requestDetail, error: error)
        print("count DetailHistory is =\(self.countDtailHistory)")
        self.loadData()
        self.refreshUI()
    }

    func getData(bill_id: String) {
        APIManager.getDetailHistory(bill_id)
    }
    
    func showAlert(title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let actionOK = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler:{ (UIAlertAction) in
            
        })
        alertView.addAction(actionOK)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    func loadData() {
        let coreData = CoreData()
        let managedObjectContext = coreData.managedObjectContext
        let request = NSFetchRequest(entityName: "DetailHistory")
        let sort = NSSortDescriptor(key: "bill_id", ascending: true)
        request.sortDescriptors = [sort]
        result = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try result.performFetch()
        } catch {
            fatalError("Error in fetching record")
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if (self.result.fetchedObjects as! [DetailHistory]).count > 0 {
            let quantity = JSON(data: (self.result.fetchedObjects as! [DetailHistory])[0].orders! as! NSData)
            countCell = quantity.count + 3
            return countCell
        } else {
            countCell = 1
            return countCell
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell!
        let index = indexPath.row
        if (self.result.fetchedObjects as! [DetailHistory]).count == 0 {
            let dequecell = self.tableView.dequeueReusableCellWithIdentifier(cellID[4], forIndexPath: indexPath) as? EmptyCellCustom
            cell = dequecell
        } else {
            if index == 0 {
                if let dequecell = self.tableView.dequeueReusableCellWithIdentifier(cellID[0], forIndexPath: indexPath) as? DetailHistoryCell1 {
                    dequecell.dateCell1.text = "asdasdsa"
                    let a = JSON(data: (self.result.fetchedObjects as! [DetailHistory])[0].restaurant as! NSData)
                    let data = String((self.result.fetchedObjects as! [DetailHistory])[0].date!)
                    let format="yyyy-MM-dd'T'HH:mm:ssZ"
                    let dateFmt = NSDateFormatter()
                    dateFmt.dateFormat = format
                    let newreadableDate = dateFmt.dateFromString(data)
                    print(newreadableDate!)
                    let finalFormatter = NSDateFormatter()
                    finalFormatter.dateFormat = "yyyy.MM.dd - HH:mm"
                    let finalDate = finalFormatter.stringFromDate(newreadableDate!)
                    dequecell.dateCell1.text = finalDate
                    for (_,_):(String,JSON) in a {
                        if a["name"].rawString()! != "null" {
                            dequecell.name.text = a["name"].rawString()!.uppercaseString
                        }
                        
                        if a["address"].rawString()! != "null" {
                            dequecell.address.text = a["address"].rawString()!
                        }
                        
                        if a["website"].rawString()! != "null" {
                            dequecell.website.text = a["website"].rawString()!
                        }
                        
                        if a["phone"].rawString()! != "null" {
                            dequecell.phone.text = a["phone"].rawString()!
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
                    let b = JSON(data: (self.result.fetchedObjects as! [DetailHistory])[0].orders! as! NSData)
                    let d = b[index - 2].dictionary
                    if d!["quantity"]!.rawString()! != "null" {
                        dequecell.quantity.text = d!["quantity"]!.rawString()!
                    }
                    if d!["item"]!.rawString()! != "null" {
                        let c = d!["item"]!.dictionary
                        if c!["name"]!.rawString()! != "null" {
                            dequecell.name.text = c!["name"]!.rawString()
                        }
                    }
                    if d!["price"]!.rawString()! != "null" {
                        dequecell.price.text = String(VND(minorUnits: d!["price"]!.int!))
                    }
                    cell = dequecell
                }
            } else if index == (countCell - 1) {
                if let dequecell = self.tableView.dequeueReusableCellWithIdentifier(cellID[2], forIndexPath: indexPath) as? DetailHistoryCell3{
                    
                    dequecell.subtotal.text = String(VND(minorUnits: Int((self.result.fetchedObjects as! [DetailHistory])[0].subTotalDetal!)))
                    dequecell.tax.text = String(VND(minorUnits: Int((self.result.fetchedObjects as! [DetailHistory])[0].tax!)))
                    dequecell.total.text = String(VND(minorUnits: Int((self.result.fetchedObjects as! [DetailHistory])[0].total!)))
                    cell = dequecell
                }
            }
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
   
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(false)
    }
   
    func deleteData(){
        do {
            let coreData = CoreData()
            let managedObjectContext = coreData.managedObjectContext
            let coord = coreData.persistentStoreCoordinator
            let fetchResquest = NSFetchRequest(entityName: "DetailHistory")
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (self.result.fetchedObjects as! [DetailHistory]).count == 0 {
            return 200
        } else {
            if indexPath.row == 0 {
                return 200
            }
            if indexPath.row >= 1 && indexPath.row < (countCell - 1){
                return 40
            }
            if indexPath.row == (countCell - 1)  {
                return 200
            }
        }        
        return 200
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func refreshUI() {
        dispatch_async(dispatch_get_main_queue(),{
            self.tableView.reloadData()
        });
    }
    
}
