//
//  Languages.swift
//  iOrder
//
//  Created by mhtran on 6/28/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit
import SwiftString

class Languages: UIViewController,UITableViewDelegate, UITableViewDataSource{

    var app: AppDelegate? = nil
    @IBOutlet weak var back: UIButton!
    
    @IBOutlet weak var naviBar: UIView!
    @IBOutlet weak var languageLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    let availbleLanguages = Localize.availableLanguages()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        app = UIApplication.sharedApplication().delegate as? AppDelegate
        back.setImage(UIImage(named: "arrow.png"),inFrame: CGRectMake(10, 13, 18, 18),forState: UIControlState.Normal)
        app!.viewDict["Language"] = self
        self.naviBar.backgroundColor = app!.genererValue.color
        self.naviBar.hidden = false
        self.tableView.allowsMultipleSelection = true
        self.tableView.reloadData()
    }

    func setText(){
        languageLabel.text = "Language".localized()
        self.tableView.reloadData()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        languageLabel.text = "Language".localized()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availbleLanguages.count - 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = self.tableView!.dequeueReusableCellWithIdentifier("language")! as UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "language")
        }

        cell!.detailTextLabel?.text = Localize.displayNameForLanguage(availbleLanguages[indexPath.row + 1])
        cell!.textLabel?.text = cell!.detailTextLabel?.text
        if availbleLanguages[indexPath.row + 1] == Localize.currentLanguage() {
            cell?.accessoryType = .Checkmark
        } else {
            cell?.accessoryType = .None
        }
        cell?.tintColor = app?.genererValue.color
        return cell!
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        Localize.setCurrentLanguage(availbleLanguages[indexPath.row + 1])
    }

    @IBAction func back(sender: AnyObject) {
        self.navigationController?.pushViewController({
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier(SEGUE_CONTAINER) as! KYDrawerController
            return vc
            }(), animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        app.navitabbar.hideNaviBarTabbar()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Languages.setText), name: LCLLanguageChangeNotification, object: nil)
        self.navigationController?.navigationBarHidden = true
        UIApplication.sharedApplication().statusBarHidden = true
        showStatusBar()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
