//
//  ChangePassVC.swift
//  iOrder
//
//  Created by mhtran on 6/29/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ChangePassVC: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var naviCustom: UIView!
    @IBOutlet weak var changePassLabel: UILabel!
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var currentTextField: UITextField!
    @IBOutlet weak var newPassTextField: UITextField!
    @IBOutlet weak var confirmPass: UITextField!
    @IBOutlet weak var changPassButton: UIButton!
    let keychain = KeychainSwift()
    var user: UserClass!
    override func viewDidLoad() {
        super.viewDidLoad()
        let app = UIApplication.sharedApplication().delegate as? AppDelegate
        app?.viewDict["ChangePassVC"] = self
        back.setImage(
            UIImage(named: "arrow.png"),
            inFrame: CGRectMake(10, 13, 16, 16),
            forState: UIControlState.Normal
        )
        naviCustom.backgroundColor = app?.genererValue.color
        setText()
        getDataUser()
        UITextField.connectFields([currentTextField,newPassTextField,confirmPass])
    }
    
    @IBAction func currentPass(sender: AnyObject) {
    }
    
    @IBAction func currentDidEnd(sender: AnyObject) {
    }
    
    @IBAction func newPassDidEnd(sender: AnyObject) {

    }
    
    @IBAction func confirmDidEnd(sender: AnyObject) {

    }
    
    
    @IBAction func newpass(sender: AnyObject) {

    }
    @IBAction func reNewpass(sender: AnyObject) {

    }
    
    func setText() {
        changePassLabel.text = "Change password".localized()
        changePassLabel.font = UIFont(name: "HelveticaNeue", size: 20)
        currentTextField.attributedPlaceholder = NSAttributedString(string:"Current Password".localized(),
                                                                    attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        newPassTextField.attributedPlaceholder = NSAttributedString(string:"New Password".localized(),
                                                                    attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        confirmPass.attributedPlaceholder = NSAttributedString(string:"Confirm Password".localized(),
                                                               attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        changPassButton.setTitle("Update".localized(), forState: .Normal)
        confirmPass.delegate = self
        confirmPass.addTarget(self, action: #selector(ChangePassVC.textFieldShouldReturn(_:)), forControlEvents: .EditingDidEndOnExit)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Dismiss the keyboard
        // Execute additional code
        changePass()
        return true
    }
    
    @IBAction func EditDid(sender: AnyObject) {
//        changePass()
    }
    
    @IBAction func backAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    func getDataUser() {
        let token = keychain.get(TOKEN)!
        let API_SHOW_ACOUNT = "\(APIManager.baseURLString)users/profile?token=\(token)"
        let url = NSString(format: API_SHOW_ACOUNT, token)
        Alamofire.request(.GET, NSURL(string: url as String)!).responseJSON { (response) in
            let json = JSON(response.result.value!)
            guard json["status_code"].rawString()! == "null" else {
                var error: String = ""
                for (_,subJson):(String,JSON) in (json["errors"].dictionary)! {
                    error = subJson[0].string!
                }
                self.showAlert("Error", message: "\(error)")
                self.view.endEditing(true)
                return
            }
            self.user = nil
            self.user = UserClass.parser(json)
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let actionOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction) in
            
        })
        alertView.addAction(actionOK)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    @IBAction func changePassAction(sender: AnyObject) {
        changePass()
    }
    
    func changePass() {
        APIManager.changPass(user.name, email: user.email, currentPass: currentTextField!.text!, confirmPass: confirmPass.text!, newPass: newPassTextField!.text!) { (check, error) in
            if check == 1 {
                self.showAlert("Error".localized(), message: "\(error)")
                self.view.endEditing(true)
            }               else if check == 2 {
                let alertView = UIAlertController(title: "Done".localized(), message: "Your password has been changed".localized(), preferredStyle: UIAlertControllerStyle.Alert)
                let actionOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction) in
                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier(SEGUE_CONTAINER) as! KYDrawerController
                    self.navigationController?.pushViewController(vc, animated: false)
                })
                alertView.addAction(actionOK)
                self.presentViewController(alertView, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        app.navitabbar.hideNaviBarTabbar()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        UIApplication.sharedApplication().statusBarHidden = true
        showStatusBar()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
}
