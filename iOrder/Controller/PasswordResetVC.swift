//
//  PasswordResetVC.swift
//  iOrder
//
//  Created by mhtran on 4/23/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class PasswordResetVC: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var userNameLab: UILabel!
    var app : AppDelegate! = nil
    @IBOutlet weak var gra1: UIGradientImageView2!
    
    @IBOutlet weak var resetPassLabel: UILabel!
    @IBOutlet weak var sendLabel: MaterialButton!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        app = UIApplication.sharedApplication().delegate as! AppDelegate
        backButton.setImage(
            UIImage(named: "arrow.png"),
            inFrame: CGRectMake(40, 40, 18, 18),
            forState: UIControlState.Normal
        )
        self.app.viewDict["PasswordResetVC"] = self
        setText()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden =  true
        UIApplication.sharedApplication().statusBarHidden = true
        cornerImage()
    }
    
    func cornerImage() {
        gra1.layer.masksToBounds = true
        gra1.layer.cornerRadius = 8
    }
    
    func setText() {
        resetPassLabel.text = "ResetPassword".localized()
        sendLabel.setTitle("Send".localized(), forState: .Normal)
        userNameLab.text = "Email".localized()
        textFieldEmail.delegate = self
        textFieldEmail.addTarget(self, action: #selector(PasswordResetVC.textFieldShouldReturn(_:)), forControlEvents: UIControlEvents.EditingDidEndOnExit)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.resignFirstResponder()
        sendToServer()
        return true
    }
    
    func sendToServer() {
        APIManager.resetAccount(textFieldEmail.text!) { (check, error) in
            if check == 0 {
                self.showAlert("Success".localized(), message: "Please login your mail to reset password.")
            } else if check == 1 {
                self.showAlert("Error", message: "Current we cant reset your password, please try another time.".localized())
            }
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
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    @IBAction func resetPassword(sender: AnyObject) {
        sendToServer()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }

    @IBAction func cancelAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    @IBAction func didBegintextField(sender: AnyObject) {
        userNameLab.hidden = true
    }
    
    
    @IBAction func endEditTexField(sender: AnyObject) {
        if textFieldEmail.text == "" {
            self.userNameLab.hidden = false
        }
    }

}
