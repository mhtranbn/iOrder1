//
//  ContainerMenuVC.swift
//  iOrder
//
//  Created by mhtran on 5/17/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit

import CoreData

class ContainerMenuVC: ContainerVC{
    
    var result: NSFetchedResultsController!
    var data:[Categorys] = []
    var idCategory: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        let coreData = CoreData()
        managedObjectContext = coreData.managedObjectContext
        titleBarDataSource.removeAll()
        loadData()
        data = result.fetchedObjects as! [Categorys]
        for i in 0...(data.count - 1) {
            titleBarDataSource.append(data[i].name!.uppercaseString)
            idCategory.append(data[i].id!)
        }
        // Do any additional setup after loading the view, typically from a nib.
        swipeableView.currentPageIndex = app.cPageIndex
        swipeableView.titleBarDataSource = titleBarDataSource
        swipeableView.delegate = self
        swipeableView.viewFrame = CGRectMake(0.0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
        self.addChildViewController(swipeableView)
        self.view.addSubview(swipeableView.view)
        swipeableView.didMoveToParentViewController(self)
        app!.viewDict["ContainerMenuVC"] = self
    }
    
    func loadData() {
        let request = NSFetchRequest(entityName: "Categorys")
        let sort = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sort]
        result = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try result.performFetch()
        } catch {
            fatalError("Error can get data")
        }
    }

    override func didLoadViewControllerAtIndex(index: Int) -> UIViewController {
        switch index {
        case 0...titleBarDataSource.count:
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier(SEGUE_LIST_ITIEMS) as! MenuVC
            vc.catergoryId = idCategory[index]
            return vc
        
        default:
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier(SEGUE_LIST_ITIEMS) as! MenuVC
            vc.catergoryId = idCategory[index]
            return vc
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
//        showMenuBar()
        app = UIApplication.sharedApplication().delegate as! AppDelegate
        (app.viewDict["KYDrawerController"] as! KYDrawerController).titleNaVi.text = "Menu".localized()
        (app.viewDict["KYDrawerController"] as! KYDrawerController).navigationController?.navigationBarHidden = false
        (app.viewDict["KYDrawerController"] as! KYDrawerController).searchBar.hidden = false
    }
}
