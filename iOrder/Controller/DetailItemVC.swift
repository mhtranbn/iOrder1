//
//  DetailItemVC.swift
//  iOrder
//
//  Created by mhtran on 7/10/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import AlamofireImage
import Money
import CoreData

class DetailItemVC: UIViewController ,UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate{

    var app :AppDelegate! = nil
    var cellID = ["$","$$","#","##","###","####"]
    var data: Items?
    var count: Int = 0
    var index: Int = 0
    var catergoryId: String? = ""
    var managedObjectContext: NSManagedObjectContext!
    var result: NSFetchedResultsController!
    var resultCountOptionAtType: NSFetchedResultsController!
    var resultOption: NSFetchedResultsController!
    var resultValue: NSFetchedResultsController!
    var countOption: Int = 0
    var arrayType: [String] = []
    var check : Bool = false
    let keychain = KeychainSwift()
    var dataArrayImage: [String] = []
    var flag: Bool = false
    enum optionType: String{
        case choice
        case addition
    }
    @IBOutlet weak var naviCustom: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameItem: UILabel!
    var mainStoryBoard: UIStoryboard?
    var mainPage: UIViewController?
    var mainPageNav: UINavigationController?
    var idItems :String = ""
    
    var totalValue : [Value] = []
    var totlaOption : [Option] = []
    var a:[Option] = []
    var c:[Option] = []
    var d: [Value] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let coreData = CoreData()
        managedObjectContext = coreData.managedObjectContext
        self.automaticallyAdjustsScrollViewInsets = false
        app = UIApplication.sharedApplication().delegate as! AppDelegate
        app.viewDict["DetailItemVC"] = self
        mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        mainPage = mainStoryBoard!.instantiateViewControllerWithIdentifier(SEGUE_LOGGED_IN) as! LoginVC
        mainPageNav = UINavigationController(rootViewController: mainPage!)
        naviCustom.backgroundColor = app.genererValue.color
        backButton.setImage(
            UIImage(named: "arrow.png"),
            inFrame: CGRectMake(backButton.center.x - 9, backButton.center.y - 9, 18, 18),
            forState: UIControlState.Normal
        )
        self.deleteAllCoreData()
        
        // get item ha
        if app.flagsSearchVC == true {
//            app.flagsSearchVC = false
            loadDataSearch()
            data = (result.fetchedObjects as! [Items])[0]
        } else {
            loadData()
            data = (result.fetchedObjects as! [Items])[index]
        }
        self.tableView.rowHeight = 60
        let nibCell1 = UINib(nibName: "PageViewCell", bundle: nil)
        self.tableView.registerNib(nibCell1, forCellReuseIdentifier: cellID[0])
        let nibCell2 = UINib(nibName: "PreferencesCell", bundle: nil)
        self.tableView.registerNib(nibCell2, forCellReuseIdentifier: cellID[1])
        let nibCell3 = UINib(nibName: "DetailCell1", bundle: nil)
        self.tableView.registerNib(nibCell3, forCellReuseIdentifier: cellID[2])
        let nibCell4 = UINib(nibName: "DetailCell2", bundle: nil)
        self.tableView.registerNib(nibCell4, forCellReuseIdentifier: cellID[3])
        let nibCell5 = UINib(nibName: "DetailCell3", bundle: nil)
        self.tableView.registerNib(nibCell5, forCellReuseIdentifier: cellID[4])
        let nibCell6 = UINib(nibName: "DetailCell4", bundle: nil)
        self.tableView.registerNib(nibCell6, forCellReuseIdentifier: cellID[5])
        self.nameItem.text = data?.name
        self.tableView.allowsSelection = false
        self.tableView.tableHeaderView = UIView()
        dataArrayImage = getArrayImage()
        getOptionData()
        
        totalValue = resultValue.fetchedObjects as! [Value]
        totlaOption = resultOption.fetchedObjects as! [Option]
        for i in 0...totlaOption.count - 1 {
            if totlaOption[i].type == optionType.choice.rawValue {
                a.append(totlaOption[i])
            } else if totlaOption[i].type == optionType.addition.rawValue {
                c.append(totlaOption[i])
            }
        }
//        dequecell.setData(d,nameOption: a[index - 2].name!)

    }
    
    func setDataItems(index: Int, catergoryID: String) {
        self.index = index
        self.catergoryId = catergoryID
    }
    
    func getDataItemsSearch(idItems: String) {
        self.idItems = idItems
    }
    func loadDataSearch() {
        let coreData = CoreData()
        managedObjectContext = coreData.managedObjectContext
        let request = NSFetchRequest(entityName:"Items")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = NSPredicate(format: "id = %@", String(idItems))
        result = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try result.performFetch()
        } catch {
            fatalError("error get data Items")
        }
    }
    
    func loadData(){
        let coreData = CoreData()
        managedObjectContext = coreData.managedObjectContext
        let request = NSFetchRequest(entityName:"Items")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = NSPredicate(format: "category_id = %@", String(catergoryId!))
        result = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try result.performFetch()
        } catch {
            fatalError("error get data Items")
        }
    }
    
    func loadDataOption() {
        let coreData = CoreData()
        managedObjectContext = coreData.managedObjectContext
        let request = NSFetchRequest(entityName: "Option")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        resultOption = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try resultOption.performFetch()
        }catch {
            fatalError("Error get Option data")
        }
    }
    
    func loadDataValue() {
        let coreData = CoreData()
        managedObjectContext = coreData.managedObjectContext
        let request = NSFetchRequest(entityName: "Value")
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        resultValue = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try resultValue.performFetch()
        }catch {
            fatalError("Error get Value data")
        }
    }
    
    func getArrayImage() -> [String] {
        guard data != nil else{
            return []
        }
        let a = JSON(data: data!.thumbs!)
        var arrayImageData:[String] = []
        for (_,_):(String,JSON) in a {
            for i in 0...(a.count - 1){
                arrayImageData.append(a[i].rawString()!)
            }
        }
        return arrayImageData
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard resultOption != nil || resultValue != nil else {
            countOption = 4
            return countOption
        }
        guard (resultOption.fetchedObjects as! [Option]).count > 0 else{
            countOption = 4
            return countOption
        }
        countOption = 0
        countOption = (resultOption.fetchedObjects as! [Option]).count + 4
        return countOption
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        let index = indexPath.row

        if index == 0 {
            if let dequecell = tableView.dequeueReusableCellWithIdentifier(cellID[0], forIndexPath: indexPath) as? PageViewCell {
                dequecell.arrayImageData = dataArrayImage
                dequecell.showImage()
                cell = dequecell
            }
        }
        if index == 1 {
            if let dequecell = tableView.dequeueReusableCellWithIdentifier(cellID[1], forIndexPath: indexPath) as? PreferencesCell {
                dequecell.upDateRating(data!.rate!.doubleValue)
                dequecell.descriptionItem.text = data!.descriptions!
                dequecell.ratingCallBack = { (check,rating) in
                    if check == 0 {
                            APIManager.createRate((self.data?.id)!, params: ["rate" : "\(String(Int(rating)))"], callBack: { (check, error) in
                                if check == 0 {
                                    print(error)
                                } else {
                                    print(error)
                                }
                            })
                    } else {
                        dequecell.upDateRating(rating)
                    }
                }
                cell = dequecell
            }
        }
        if countOption > 4 && resultOption != nil{
            self.tableView.separatorStyle = .SingleLine
            if index >= 2 && index <= a.count + 1 {
                for i in 0...totalValue.count - 1{
                    if totalValue[i].option_id! == a[index - 2].id!{
                        app.optionValue.append(totalValue[i])
                    }
                }
            }
            if index >= 2 && index <= a.count + 1 {
                if let dequecell = tableView.dequeueReusableCellWithIdentifier(cellID[2], forIndexPath: indexPath) as? DetailCell1 {
                    app.option.name["\(a[index - 2].name)"] = ""
                    dequecell.kindOfOptions.text = a[index - 2].name
                    dequecell.pickerView.reloadData()
                    dequecell.selectionCallback = {
                        self.tableView.reloadData()
                    }
                    cell = dequecell
                }
            } else if index <= totlaOption.count + 1 && index >= a.count + 2{
                if let dequecell = tableView.dequeueReusableCellWithIdentifier(cellID[3], forIndexPath: indexPath) as? DetailCell2 {
                    var idValue: String = ""
                    var idOption: String = ""
                    var nameOption: String = ""
                    var nameValue: String = ""
                    for i in 0...totalValue.count - 1{
                        if totalValue[i].option_id! == c[index - a.count - 2].id!{
//                            app.option.options["\(totalValue[i].option_id!)"] = ""
                            dequecell.price.text = String(VND(minorUnits: Int(totalValue[i].price!)))
                            dequecell.name.text = c[index - a.count - 2].name
                            dequecell.totalPriceForOption = Int(totalValue[i].price!)
                            idValue = totalValue[i].id!
                            nameOption = c[index - a.count - 2].name!
                            if totalValue[i].name != nil {
                                nameValue = totalValue[i].name!
                            } else {
                                nameValue = "null"
                            }
                            idOption = totalValue[i].option_id!
                        }
                    }
                    dequecell.selectionCallback = {
                        if dequecell.bool == true {
                            self.app.option.options["\(idOption)"] = idValue
                            self.app.option.name["\(nameOption)"] = nameValue
                        } else if dequecell.bool == false{
                            self.app.option.options["\(idOption)"] = ""
                            self.app.option.name["\(nameOption)"] = ""
                        }
                        self.tableView.reloadData()
                    }
                    cell = dequecell
                }
            }
        }
        
        if index == countOption - 2 {
            if let dequecell = tableView.dequeueReusableCellWithIdentifier(cellID[4],forIndexPath: indexPath) as? DetailCell3 {
                dequecell.selectionCallback = {
                    self.tableView.reloadData()
                }
                cell = dequecell
            }
            
        } else if index == countOption - 1 {
            if let dequecell = tableView.dequeueReusableCellWithIdentifier(cellID[5],forIndexPath: indexPath) as? DetailCell4{
                dequecell.total.text = String(VND(minorUnits: ((Int(data!.price!) + app.priceTotalOptions) * app.number)))
                if self.check == true {
                    dequecell.check.checked = true
                } else {
                    dequecell.check.checked = false
                }
                dequecell.selectionCallBack = {
                    self.check = dequecell.check.checked
                }
                dequecell.ratingCallBack = {
                    
                }
                dequecell.orderCallBack = {
                    self.orderItemsAction()
                    self.deleteAllCoreData()
                }
                cell = dequecell
            }
        }
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let index = indexPath.row
        if index == 0 {
           return 300
        }
        if index == 1 {
            return 200
        }
        if index < countOption - 1 && index > 1{
            return 60
        } else if index == countOption - 1 {
            return 300
        }
        return 60
    }
    
    func getOptionData(){
        let coreData = CoreData()
        managedObjectContext = coreData.managedObjectContext
        guard data?.option != nil else {
            return
        }
        let dataOption = data?.option
        let jsonOption = JSON(data: dataOption! as NSData).array
        guard let countOption = jsonOption?.count where jsonOption?.count > 0 else {
            return
        }
        for i in 0...(countOption - 1) {
            var optionID = ""
            let options = NSEntityDescription.insertNewObjectForEntityForName("Option", inManagedObjectContext: managedObjectContext) as! Option
            let dataAnOption = jsonOption![i].dictionaryValue
            if dataAnOption["id"]?.rawString()! != "null" {
                options.id = dataAnOption["id"]!.string!
                optionID = dataAnOption["id"]!.rawString()!
            }
            
            if dataAnOption["optionName"]?.rawString()! != "null" {
                options.name = dataAnOption["optionName"]!.string!
            }
            
            if dataAnOption["optionType"]?.rawString()! != "null" {
                options.type = dataAnOption["optionType"]!.string!
                
            } else {
                options.type = ""
            }
            
            if dataAnOption["optionDescription"]?.rawString()! != "null" {
                options.optionDescription = dataAnOption["optionDescription"]!.string!
            }
            
            let dataValue = dataAnOption["values"]!.array
            guard let countValue = dataValue?.count where dataValue?.count > 0 else {
                return
            }
            for j in 0...(countValue - 1) {
                let value = NSEntityDescription.insertNewObjectForEntityForName("Value", inManagedObjectContext: managedObjectContext) as! Value
                let dataAnValue = dataValue![j].dictionary!
                value.option_id = optionID
                if dataAnValue["id"]?.rawString()! != "null" {
                    value.id = dataAnValue["id"]!.string!
                }
                if dataAnValue["valueName"]?.rawString()! != "null" {
                    value.name = dataAnValue["valueName"]!.string!
                }
                if dataAnValue["valuePrice"]?.rawString()! != "null" {
                    value.price = dataAnValue["valuePrice"]!.number
                } else {
                    value.price = 0
                }
                if dataAnValue["valueDescription"]?.rawString()! != "null" {
                    value.valueDescription = dataAnValue["valueDescription"]!.string!
                }
            }
        }
        coreData.saveContext()
        let request = NSFetchRequest(entityName: "Option")
        let request2 = NSFetchRequest(entityName: "Value")
        let error: NSErrorPointer = nil
        self.countOption = 0
        self.countOption = coreData.managedObjectContext.countForFetchRequest(request, error: error)
        _ = coreData.managedObjectContext.countForFetchRequest(request2, error: error)
        if countOption > 0 {
            loadDataValue()
            loadDataOption()
            self.tableView.reloadData()
        }
    }
    
    func orderItem() {
        count = self.app.number
        // remove option zero and get key and value
        //check item buy have option
        var clean:[String: String]?
        var cleanName:[String: String]?
        var arrKey = [String]()
        var arrValue = [String]()
        var arrKeyName = [String]()
        var arrValueName = [String]()
        if app.option.options == [:] {
            clean = [:]
            cleanName = [:]
        } else {
            clean = Dictionary(
                app.option.options.flatMap(){
                    return ($0.1 == "") ? .None : $0
                })
            cleanName = Dictionary(
                app.option.name.flatMap(){
                    return ($0.1 == "") ? .None : $0
                })
            for (key, value) in clean!{
                arrKey.append("\(key)")
                arrValue.append("\(value)")
            }
            for (key, value) in cleanName! {
                arrKeyName.append("\(key)")
                arrValueName.append("\(value)")
            }
        }
        // check add to list
        if check == true {
            var a:ListaddOrder? = ListaddOrder(id: data!.id!, count: count, image: getArrayImage()[0], price:Int(data!.price! ) + app.priceTotalOptions, name: data!.name!, options: clean!, nameOV: cleanName!,description: data!.descriptions!)
            app.listOrder.append(a!)
            a = nil
            app.option.options.removeAll()
            app.option.name.removeAll()            
            app.flagBadgeAnimate = true
        } else {
            // ORDER SEND TO SERVER
            var params2 = Dictionary<String,AnyObject>()
            var params3 = Dictionary<String,AnyObject>()
            if clean!.count == 0 {
                params2 = ["table_id":"\((app?.genererValue.table_id)!)","item_id":"\((data!.id)!)","quantity":"\(count)"]
            } else {
                params2 = [
                    "table_id":"\((app?.genererValue.table_id)!)",
                    "item_id":"\((data!.id)!)",
                    "quantity":"\(count)",
                ]
                for i in 0...clean!.count - 1 {
                    params3["options\(i + 1)"] = ["value_id":"\(arrValue[i])",
                                                  "option_id":"\(arrKey[i])"
                    ]
                }
                print(params3)
                params2["options"] = params3
                params3.removeAll()
                clean?.removeAll()
                arrKey.removeAll()
                arrValue.removeAll()
                app.option.options.removeAll()
            }
            print(params2)
            APIManager.orderItem(params2)
            if app.flagsSearchVC == true {
                //            app.flagsSearchVC = false
                loadDataSearch()
                (result.fetchedObjects as! [Items])[0].quantity = NSNumber(int: 1 + Int((result.fetchedObjects as! [Items])[0].quantity!))
            } else {
                loadData()
                (result.fetchedObjects as! [Items])[index].quantity =  NSNumber(int: 1 + Int((result.fetchedObjects as! [Items])[index].quantity!))
            }
            try! self.managedObjectContext.save()
            params2.removeAll()
        }
        
        if app.flagsSearchVC == true {
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            presentingViewController?.dismissViewControllerAnimated(true, completion: {
                self.callRootView()
            })
        }
    }
    
    func callRootView() {
        self.mainPage = self.mainStoryBoard!.instantiateViewControllerWithIdentifier(SEGUE_CONTAINER) as! KYDrawerController
        self.app.flagJumpToMenuVC = true
        self.mainPageNav = UINavigationController(rootViewController: self.mainPage!)
        self.app?.window?.rootViewController = self.mainPageNav
    }
    
    func callRootSearchView() {
        self.mainPage = self.mainStoryBoard!.instantiateViewControllerWithIdentifier(SEGUE_SEARCHCONTROLLER) as! SearchVC
        self.mainPageNav = UINavigationController(rootViewController: self.mainPage!)
        self.app?.window?.rootViewController = self.mainPageNav
    }
    
    func orderItemsAction() {
        app = UIApplication.sharedApplication().delegate as! AppDelegate
        if Defaults["login"].boolValue == false {
            (mainPage as! LoginVC).goDetail = true
            (mainPage as! LoginVC).checkAddList = self.check
            app?.window?.rootViewController = mainPageNav
        } else {
            orderItem()
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let actionOK = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler:{ (UIAlertAction) in
            
        })
        alertView.addAction(actionOK)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        app.navitabbar.hideNaviBarTabbar()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        TABBAR_HEIGHT = CGFloat(0)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        TABBAR_HEIGHT = CGFloat(60)
    }
    
    @IBAction func back(sender: AnyObject) {
        TABBAR_HEIGHT = CGFloat(60)
        app.navitabbar.hideSearchBar()
        self.deleteAllCoreData()
        if app.flagsSearchVC == true {
            app.flagsSearchVC = false
            callRootSearchView()
        } else{
            callRootView()
        }
    }
    
    func deleteAllCoreData() {
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        app.number = 1
        app.optionChoose = 0
        app.optionValue.removeAll()
        app.priceTotalOptions = 0
        do {
            let coreData = CoreData()
            let coord = coreData.persistentStoreCoordinator
            let fetchRequest5 = NSFetchRequest(entityName: "Option")
            let fetchRequest6 = NSFetchRequest(entityName: "Value")
            if #available(iOS 9.0, *) {
                let deteleResquest5 = NSBatchDeleteRequest(fetchRequest: fetchRequest5)
                let deteleResquest6 = NSBatchDeleteRequest(fetchRequest: fetchRequest6)
                do {
                    try coord.executeRequest(deteleResquest5, withContext: coreData.managedObjectContext)
                    try coord.executeRequest(deteleResquest6, withContext: coreData.managedObjectContext)
                } catch _ as NSError{
                }
            } else {
                // earlier versions
                do {
                    for request in [fetchRequest5,fetchRequest6] {
                        coreData.deleteCoreData(request)
                    }
                }

            }
            
        }
    }
}
