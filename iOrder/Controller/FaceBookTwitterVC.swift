//
//  FaceBookTwitterVC.swift
//  iOrder
//
//  Created by mhtran on 5/23/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit

class FaceBookTwitterVC: UIViewController {
    
    @IBOutlet weak var ftView: UIWebView!
    
    var URL = "https://www.facebook.com/AmericanUniversity"
    var tw = "https://twitter.com/mhtranbn"
    var app: AppDelegate? = nil
    @IBOutlet weak var backButton: UIButton!
    func loadfacebook()
    {
        let requestfbURL = NSURL(string: URL)
        let fbRequest = NSURLRequest(URL: requestfbURL!)
        ftView.loadRequest(fbRequest)
        
    }
    override func viewDidLoad() {
        loadfacebook()
        super.viewDidLoad()
        app = UIApplication.sharedApplication().delegate as? AppDelegate
        self.app?.viewDict["FaceBookTwitterVC"] = self
        app?.navitabbar.hideNaviBarTabbar()
        setText()
    }
    
    func setText() {
        backButton.setTitle("Back to Home".localized(), forState: .Normal)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    //back Home
    
    @IBAction func backHome(sender: AnyObject) {
        if(ftView.canGoBack) {
            //Go back in webview history
            ftView.goBack()
        } else {
            //Pop view controller to preview view controller
            app?.navitabbar.showNaviTabBar()
            self.navigationController?.popViewControllerAnimated(false)
            
        }

        
    }
    
}