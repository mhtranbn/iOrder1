//
//  SearchVC.swift
//  iOrder
//
//  Created by mhtran on 5/25/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import CoreData
import SwiftyJSON
import Money
import Kingfisher
import SwiftString

protocol SearchResultsViewControllerDelegate {
    func reassureShowingList() -> Void
}

class SearchVC: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UISearchControllerDelegate, UISearchBarDelegate{
    let tableData = []
    var items: [Items] = []
    var filteredTableData :[Items] = []
    var marrCountryList = [String]()
    var marrFilteredCountryList = [String]()
    var managedObjectContext : NSManagedObjectContext!
    var resultSearchController = UISearchController()
    var result: NSFetchedResultsController!
    var resultSearch: NSFetchedResultsController!
    var catergoryId: String! = ""
    var nameItems: String = ""
    var delegate: SearchResultsViewControllerDelegate?
    var app : AppDelegate!
    let transition = Animator()
    var selectedImage: UIGradientImageView?
    var hightKeyboard: CGFloat = 0
    var cellID:[String] = []
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var navi: UIView!
//    var searchBar: UISearchBar
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let coreData = CoreData()
        managedObjectContext = coreData.managedObjectContext
        app = UIApplication.sharedApplication().delegate as! AppDelegate
        addRefreshController()
        backButton.setImage(
            UIImage(named: "arrow.png"),
            inFrame: CGRectMake(10, 30, 16, 16),
            forState: UIControlState.Normal
        )
        cellID = ["##"]
        let cellNib = UINib(nibName: "EmptyCellCustom", bundle: nil)
        self.tableView.registerNib(cellNib, forCellReuseIdentifier: cellID[0])
        self.resultSearchController.delegate = self
        if #available(iOS 9.0, *) {
            self.resultSearchController.loadViewIfNeeded()
        } else {
            // Fallback on earlier versions
        }
        app.viewDict["SearchVC"] = self
        self.resultSearchController.delegate = self
        loadData()
        items = result.fetchedObjects as! [Items]
        self.navi.backgroundColor = app.genererValue.color
        self.navi.hidden = false
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.delegate = self
            presentViewController(controller, animated:false, completion:{
            let frame = CGRect(x: self.backButton.bounds.size.width / 2 + 10, y: self.navi.bounds.size.height / 2 - 22, width: self.navi.bounds.size.width - self.backButton.bounds.size.width / 4, height: 44)
            let titleView = UIView(frame: frame)
            controller.searchBar.backgroundImage = UIImage()
            controller.searchBar.frame = frame
            titleView.addSubview(controller.searchBar)
            controller.searchBar.backgroundColor = self.app.genererValue.color
            controller.searchBar.barTintColor = self.app.genererValue.color
            controller.hidesNavigationBarDuringPresentation = false
            self.navi.addSubview(titleView)
            })
            return controller
        })()
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        self.tableView.reloadData()
    }

    func loadData() {
        let request = NSFetchRequest(entityName: "Items")
        let sort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sort]
        result = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
                try result.performFetch()
        } catch {
            fatalError("Error read data Items")
        }
    }
    
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.resultSearchController.active) {
            if self.filteredTableData.count == 0 {
              return 1
            }
            return self.filteredTableData.count
        }
        else {
            return items.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        let index = indexPath.row
        
            if self.filteredTableData.count == 0 {
                if (self.resultSearchController.active) {
                    if let dequecell:EmptyCellCustom = self.tableView.dequeueReusableCellWithIdentifier(cellID[0], forIndexPath: indexPath) as? EmptyCellCustom {
                        let boldHelveticaFont = UIFont(name: "Helvetica Neue", size: 14)?.fontDescriptor().fontDescriptorWithSymbolicTraits(UIFontDescriptorSymbolicTraits.TraitBold)
                         dequecell.emptyLabel.font = UIFont(descriptor: boldHelveticaFont!, size: 14)
                        dequecell.emptyLabel?.text = "Opps!, No thing, please search another things :)".localized()
                        cell = dequecell
                    }
                }
            }else {
                if let dequecell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? ItemsCustomCellTableViewCell{
                    if (self.resultSearchController.active) {
                        dequecell.itemsName.text = filteredTableData[index].name
                        dequecell.itemsImage.kf_showIndicatorWhenLoading = true
                        dequecell.itemsImage.kf_setImageWithURL(getThumbFirstInArray(filteredTableData,index: index), placeholderImage: UIImage(named: "NoImage.png"),
                                                                optionsInfo: [.Transition(ImageTransition.Fade(1))],
                                                                progressBlock: { receivedSize, totalSize in
                            },
                                                                completionHandler: { image, error, cacheType, imageURL in
                        })
                        dequecell.itemsName.text = filteredTableData[index].name
                        dequecell.itemsPrice.text = String(VND(minorUnits: Int(filteredTableData[index].price!)))
                        // get item have
                        /*dequecell.showBagde(Int(self.filteredTableData[index].quantity!))*/
                        catergoryId = filteredTableData[index].category_id
                        if index == app.numberOfBagde {
                            app.numberOfBagde = 9999
                            dequecell.flagCallback = true
                        }
                        dequecell.callBack = {
                            //check Login
                            print("searc check")
                            if Defaults["login"].boolValue == false {
                                self.app.numberOfBagde = index
                                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                let mainPage: LoginVC = mainStoryboard.instantiateViewControllerWithIdentifier(SEGUE_LOGGED_IN) as! LoginVC
                                self.app.flagsSearchVC = true
                                let mainPageNavi = UINavigationController(rootViewController: mainPage)
                                self.app.window?.rootViewController = mainPageNavi
                            } else {
                                let alertView = UIAlertController(title: "Confirm!".localized(), message: "Order Now".localized(), preferredStyle: UIAlertControllerStyle.Alert)
                                let actionOK = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler:{ (UIAlertAction) in
                                    self.items[index].quantity! = NSNumber(int: 1 + Int(self.items[index].quantity!))
                                    try! self.managedObjectContext.save()
                                    /*dequecell.showBagde(Int(self.items[index].quantity!))*/
                                    APIManager.orderItem([
                                        "table_id" : "\((self.app?.genererValue.table_id)!)",
                                        "item_id" : "\(self.items[index].id!)",
                                        "quantity" : "1"
                                        ])
                                })
                                let cancelAction = UIAlertAction(title: "CANCEL".localized(), style: UIAlertActionStyle.Default, handler: nil)
                                alertView.addAction(actionOK)
                                alertView.addAction(cancelAction)
                                if self.presentedViewController == nil {
                                    self.presentViewController(alertView, animated: true, completion: nil)
                                } else{
                                    self.dismissViewControllerAnimated(false) { () -> Void in
                                        self.presentViewController(alertView, animated: true, completion: nil)
                                    }
                                }
                            }
                        }
                        cell = dequecell
                    }
                    else {
                        dequecell.itemsImage.kf_showIndicatorWhenLoading = true
                        dequecell.itemsImage.kf_setImageWithURL(getThumbFirstInArray(items, index: index), placeholderImage: UIImage(named: "NoImage.png"),
                                                                optionsInfo: [.Transition(ImageTransition.Fade(1))],
                                                                progressBlock: { receivedSize, totalSize in
                            },
                                                                completionHandler: { image, error, cacheType, imageURL in
                        })
                        dequecell.itemsName.text = items[index].name
                        dequecell.itemsPrice.text = String(VND(minorUnits: Int(items[index].price!)))
                        catergoryId = items[index].category_id
                        /*dequecell.showBagde(Int(self.items[index].quantity!))*/
                        if index == app.numberOfBagde {
                            app.numberOfBagde = 9999
                            dequecell.flagCallback = true
                        }
                        dequecell.callBack = {
                            print("Search VC check")
                            //check Login
                            if Defaults["login"].boolValue == false {
                                self.app.numberOfBagde = index
                                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                let mainPage: LoginVC = mainStoryboard.instantiateViewControllerWithIdentifier(SEGUE_LOGGED_IN) as! LoginVC
                                self.app.flagsSearchVC = true
                                let mainPageNavi = UINavigationController(rootViewController: mainPage)
                                self.app.window?.rootViewController = mainPageNavi
                            } else {
                                let alertView = UIAlertController(title: "Confirm!".localized(), message: "Order Now".localized(), preferredStyle: UIAlertControllerStyle.Alert)
                                let actionOK = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler:{ (UIAlertAction) in
                                    self.items[index].quantity! = NSNumber(int: 1 + Int(self.items[index].quantity!))
                                    try! self.managedObjectContext.save()
                                    /*dequecell.showBagde(Int(self.items[index].quantity!))*/
                                    APIManager.orderItem([
                                        "table_id" : "\((self.app?.genererValue.table_id)!)",
                                        "item_id" : "\(self.items[index].id!)",
                                        "quantity" : "1"
                                        ])
                                })
                                let cancelAction = UIAlertAction(title: "CANCEL".localized(), style: UIAlertActionStyle.Default, handler: nil)
                                alertView.addAction(actionOK)
                                alertView.addAction(cancelAction)
                                if self.presentedViewController == nil {
                                    self.presentViewController(alertView, animated: true, completion: nil)
                                } else{
                                    self.dismissViewControllerAnimated(false) { () -> Void in
                                        self.presentViewController(alertView, animated: true, completion: nil)
                                    }
                                }
                            }
                        }
                        cell = dequecell
                    }
                }
            }
        
        return cell
    }
    
    func getThumbFirstInArray(array: [Items],index: Int) -> NSURL{
        let a = NSURL(string:(JSON(data: items[index].thumbs! as NSData).array)![0].rawString()!)
        return a!
    }
    
    func checkBagde(){
        if app.flagBadgeAnimate == true {
            app.flagBadgeAnimate = false
            self.app.countBagde += 1
        }
    }
    
    func addRefreshController(){
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(SearchVC.refresh(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
    }

    func refresh(refreshCtl : UIRefreshControl){
        refreshCtl.endRefreshing()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar){
    }
    
    func hideSearchBar() {
        searchBarCancelButtonClicked(resultSearchController.searchBar)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        let query = resultSearchController.searchBar.text?.trimmed()
        filteredTableData.removeAll(keepCapacity: false)
        let coreData = CoreData()
        let manaObjectContext = coreData.managedObjectContext
        let request = NSFetchRequest(entityName: "Items")
        let sort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sort]
        if query == nil || query!.isEmpty {
            
        } else {
            let searchPredicate = NSPredicate(format: "name CONTAINS[c] %@", searchController.searchBar.text!)
            request.predicate = searchPredicate
        }
        resultSearch = NSFetchedResultsController(fetchRequest: request, managedObjectContext: manaObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try resultSearch.performFetch()
        } catch {
            fatalError("Error read data Items")
        }
        filteredTableData = resultSearch.fetchedObjects as! [Items]
        self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.filteredTableData.count == 0 {
            self.tableView.separatorStyle = .None
            return 136
        }
        return 220
    }

    func reassureShowingList() {
        resultSearchController.searchResultsController!.view.hidden = false
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.navigationController?.pushViewController({
            self.resultSearchController.searchBar.hidden = true
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("DetailItemVC") as! DetailItemVC
            app.flagsSearchVC = true
            vc.getDataItemsSearch(filteredTableData[indexPath.row].id!)
            vc.hidesBottomBarWhenPushed = false
            return vc
            }(), animated: false)
    }
    
    @IBAction func back(sender: AnyObject) {
        self.app.flagsSearchVC = false
        self.resultSearchController.active = false
        self.resultSearchController.searchBar.hidden = true
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier(SEGUE_CONTAINER) as! KYDrawerController
        app.flagJumpToMenuVC = true
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBarHidden = true
        UIApplication.sharedApplication().statusBarHidden = true
        transition.dismissCompletion = {
            self.selectedImage!.hidden = false
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.resultSearchController.searchBar.hidden = false
        let app = UIApplication.sharedApplication().delegate as? AppDelegate
        app?.navitabbar.hideNaviBarTabbar()
        checkBagde()
    }
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition({context in
            
            }, completion: nil)
    }
}
//extension
extension MenuVC: UIViewControllerTransitioningDelegate {
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