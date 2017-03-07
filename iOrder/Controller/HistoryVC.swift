//
//  HistoryVC.swift
//  iOrder
//
//  Created by mhtran on 5/19/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import SwiftyJSON
import Alamofire
import Money
import ReachabilitySwift

class HistoryVC: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var app: AppDelegate? = nil
    var historyData : [History] = []
    var result: NSFetchedResultsController!
    var reachability: Reachability?
    var callBack: (()-> Void)?
    var cellID = "#"
    var i = 2
    var maxPage: Int = 0
    var loadFirst: Bool = false
    enum network {
        case Wifi
        case Cellular
        case Richable
    }
    var net: network = .Richable
    @IBOutlet weak var myFooter: MyFooter!
    private let pageSize = 5
    private var loading = false {
        didSet {
            myFooter.hidden = !loading
        }
    }
    var countCell = 0
    
    private var history: [History] = []
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if (maximumOffset - currentOffset) <= 40{
            loadSegment(String(i))
            if i <= maxPage {
                i += 1
            } else {
                return
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        app = UIApplication.sharedApplication().delegate as? AppDelegate
        myFooter.hidden = true
        addRefreshController()
        app?.viewDict["HistoryVC"] = self
        let nibCell1 = UINib(nibName: "EmptyCellCustom", bundle: nil)
        self.tableView.registerNib(nibCell1, forCellReuseIdentifier: cellID)
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            return
        }
        if reachability!.isReachable() {
            deleteData()
            getDataHistory()
        } else {
            loadData()
            historyData = result.fetchedObjects as! [History]
            if historyData.count > 0 {
            } else {
                getDataHistory()
            }
        }
    }
    
    func loadSegment(page:String) {
        self.myFooter.bounds.size.height = 100
        if (!loading) {
            loading = true
            APIManager.getHistory(page)
            delay(3, closure: {
                self.loading = false
                self.myFooter.bounds.size.height = 0
                self.tableView.reloadData()
            })
        }
    }
    
    func addRefreshController(){
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(HistoryVC.refresh(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func refresh(refreshCtl : UIRefreshControl){
        refreshCtl.endRefreshing()
    }
    
    func deleteData() {
        do {
            let coreData = CoreData()
            let managedObjectContext = coreData.managedObjectContext
            let coord = coreData.persistentStoreCoordinator
            let fetchResquest = NSFetchRequest(entityName: "History")
            if #available(iOS 9.0, *) {
                let deleteResquest = NSBatchDeleteRequest(fetchRequest: fetchResquest)
                do {
                    try coord.executeRequest(deleteResquest, withContext: managedObjectContext)
                } catch let error as NSError {
                    fatalError("Error delete Data \(error.debugDescription)")
                }
            } else {
                // Fallback on earlier versions
                
            }
        }
    }
    
    func checkNetwork() {
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            return
        }
        if reachability!.isReachable() {
            if reachability!.isReachableViaWiFi() {
                print("Reachable via WiFi")
                net = .Wifi
            } else {
                print("Reachable via Cellular")
                net = .Cellular
            }
        } else {
            print("Network not reachable")
            net = .Richable
        }

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
        app?.navitabbar.showNaviTabBar()
    }
    // MARK: - Table view data source
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.deleteData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard result != nil else {
            self.tableView.separatorStyle = .None
            countCell = 0
            return countCell + 1
        }
        self.tableView.separatorStyle = .SingleLine
        countCell = (result.fetchedObjects as! [History]).count
        return countCell
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier: String = "HistoryCell"
        var cell: UITableViewCell!
        guard result != nil else{
            let dequecell = self.tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! EmptyCellCustom
            cell = dequecell
            return cell
        }
            if let dequecell:HistoryCell? = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? HistoryCell {
                let index = indexPath.row
                let data = result.fetchedObjects as! [History]
                let format="yyyy-MM-dd'T'HH:mm:ssZ"
                let dateFmt = NSDateFormatter()
                dateFmt.dateFormat = format
                print("asjcs=\(data[index].date!)")
                let newreadableDate = dateFmt.dateFromString(data[index].date!)
                print(newreadableDate!)
                let finalFormatter = NSDateFormatter()
                finalFormatter.dateFormat = "yyyy.MM.dd - HH:mm"
                let finalDate = finalFormatter.stringFromDate(newreadableDate!)
                dequecell!.date.text = finalDate
                dequecell!.price.text = String(VND(minorUnits: Int(data[index].total!)))
                let a = JSON(data: data[index].restaurant as! NSData).dictionary
                for (key,subJson):(String, JSON) in a! {
                    if key == "name" {
                        dequecell?.name.text = subJson.rawString()?.uppercaseString
                    }
                    if key == "location" {
                        //                let b = subJson.dictionary!
                        
                        //                cell?.address.text = (b["lat"]!.rawString())! + " , " + b["lng"]!.rawString()!
                    }
                    if key == "address" {
                        dequecell?.address.text = subJson.rawString()!
                    }
                    cell = dequecell
                }
            }
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if countCell == 1 {
            return 136
        }
        return 136
    }
    
    func saveData(json:JSON) {
//        self.deleteData()
        guard json["bills"].count > 0 else {
            return
        }
        guard json["status_code"].rawString()! == "null" else {
            var error: String = ""
            for (_,subJson):(String,JSON) in (json["errors"].dictionary)! {
                error = subJson[0].string!
            }
            self.showAlert("Error".localized(), message: "\(error)")
            self.view.endEditing(true)
            return
        }
        
        let coreData = CoreData()
        let managedObjectContext = coreData.managedObjectContext
        let bills = json["bills"]
        let meta = json["meta"]["pagination"]
        for i in 0...(bills.count - 1){
            let bill = bills[i].dictionary!
            let history = NSEntityDescription.insertNewObjectForEntityForName("History", inManagedObjectContext: managedObjectContext) as! History
            if bill["id"]!.string! != "null" {
                history.id = bill["id"]!.string
            }
            if bill["date"]!.string! != "null" {
                history.date = bill["date"]!.string
            }
            if bill["total"]!.rawString()! != "null" {
                history.total = bill["total"]!.number
            }
            if bill["restaurant"]!.rawString()! != "null" {
                do {
                    try history.restaurant = bill["restaurant"]!.rawData()
                } catch {
                    fatalError("Error get restaurant")
                }
            }
        }
        
        if meta["total_pages"].rawString()! != "null" {
            maxPage = meta["total_pages"].rawString()!.toInt()!
        }

        coreData.saveContext()
        let error: NSErrorPointer = nil
        let request = NSFetchRequest(entityName: "History")
        let historyCount = managedObjectContext.countForFetchRequest(request, error: error)
        print("Total historyCount is \(historyCount)")
        if historyCount > 0 {
            self.loadData()
            if loadFirst == false {
                loadFirst = true
                self.tableView.reloadData()
            } else {
                delay(5, closure: {
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    func getDataHistory() {
        APIManager.getHistory("1")
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
        let manaObjectContext = coreData.managedObjectContext
        let request = NSFetchRequest(entityName: "History")
        let sort = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sort]
        result = NSFetchedResultsController(fetchRequest: request, managedObjectContext: manaObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try result.performFetch()
        } catch {
            fatalError("Error fetch record")
        }
    }
 
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier(SEGUE_DETAIL_HISTORY) as? DetailHistoryVC
        self.navigationController?.pushViewController({
            vc?.bill_id = (result.fetchedObjects as! [History])[indexPath.row].id!
            return vc!
            }(), animated: false)
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 0))
        footerView.backgroundColor = UIColor.clearColor()
        return footerView
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

}
