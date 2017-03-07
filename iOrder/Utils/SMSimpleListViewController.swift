//
//  SMSimpleListViewController.swift
//  testPagingView
//
//  Created by mhtran on 5/9/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit

class SMSimpleListViewController: UITableViewController {

    var dataSource: [AnyObject]?
    var pageIndex = 0
    var buttonDataSource: [String]?
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataSource?.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CellIdentifier")
        if cell == nil{
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "CellIdentifier")
        }
        if let data = dataSource {
            cell!.textLabel?.text = data[indexPath.row] as? String
        }
        return cell!

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        app.navitabbar.showNaviTabBar()
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
