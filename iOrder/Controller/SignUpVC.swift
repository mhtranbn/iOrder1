//
//  SignUpVC.swift
//  iOrder
//
//  Created by mhtran on 4/22/16.
//  Copyright © 2016 mhtran. All rights reserved.
//
import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import CoreData
import AlamofireImage

import SystemConfiguration

class SignUpVC: UIViewController,UITextFieldDelegate{
    @IBOutlet weak var userNameSignUp: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordSignUp: UITextField!
    @IBOutlet weak var returnPaswordSignUp: UITextField!
    @IBOutlet weak var emailSignUp: UITextField!
    @IBOutlet weak var user: UILabel!
    @IBOutlet weak var userNameLab: UILabel!
    @IBOutlet weak var passwordLab: UILabel!
    @IBOutlet weak var repasswordLab: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var submitLabel: MaterialButton!
    @IBOutlet weak var signInLabel: UIButton!
    @IBOutlet weak var alreadyLabel: UILabel!
    @IBOutlet weak var gra1: UIGradientImageView2!
    @IBOutlet weak var gra2: UIGradientImageView2!
    @IBOutlet weak var gra3: UIGradientImageView2!
    @IBOutlet weak var gra4: UIGradientImageView2!
    @IBOutlet weak var gra5: UIGradientImageView2!
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    var app: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        app = UIApplication.sharedApplication().delegate as? AppDelegate
        self.app.viewDict["SignUpVC"] = self
        setText()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
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
        gra2.layer.masksToBounds = true
        gra2.layer.cornerRadius = 8
        gra3.layer.masksToBounds = true
        gra3.layer.cornerRadius = 8
        gra4.layer.masksToBounds = true
        gra4.layer.cornerRadius = 8
        gra5.layer.cornerRadius = 8
        gra5.layer.masksToBounds = true
    }
    
    func setText() {
        user.text = "Name".localized()
        userNameLab.text = "Email".localized()
        phoneLabel.text = "Phone(optional)".localized()
        passwordLab.text = "Password".localized()
        repasswordLab.text = "Re-type Password".localized()
        signUpLabel.text = "Sign Up".localized()
        submitLabel.setTitle("Submit".localized(), forState: .Normal)
        alreadyLabel.text = "Already have an account? ".localized()
        signInLabel.setTitle("Sign In".localized(), forState: .Normal)
        UITextField.connectFields([userNameSignUp,emailSignUp,phoneTextField,passwordSignUp,returnPaswordSignUp])
        returnPaswordSignUp.delegate = self
        returnPaswordSignUp.addTarget(self, action: #selector(SignUpVC.textFieldShouldReturn(_:)), forControlEvents: UIControlEvents.EditingDidEndOnExit)
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        submit()
        return true
    }
    
    @IBAction func submitSignUp(sender: AnyObject) {
        submit()
    }
    
    func submit() {
        APIManager.createAcount(userNameSignUp!.text!, emailSignUp: emailSignUp!.text!, phone:phoneTextField!.text!,passwordSignUp: passwordSignUp!.text!, returnPaswordSignUp: returnPaswordSignUp!.text!){ (check, error) in
            if check == 0 {
                self.showErrorAlert("Error".localized(), message: "\(error) Try again".localized())
            } else if check == 1 {
                self.showErrorAlert("Network error".localized(), message: "Please check your network and try again".localized())
            } else if check == 2 {
                self.showErrorAlert("SignUp Success".localized(), message: "Done".localized())
            }
        }
    }
    func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action  = UIAlertAction(title: "OK".localized(), style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func back(sender: AnyObject) {
        
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    @IBAction func beginUser(sender: AnyObject) {
        user.hidden = true
    }
    @IBAction func endUser(sender: AnyObject) {
        
        if userNameSignUp.text == "" {
            self.user.hidden = false
        }
    }
    @IBAction func beginPhone(sender: AnyObject) {
        self.phoneLabel.hidden = true
    }
    @IBAction func endPhone(sender: AnyObject) {
        if phoneTextField.text == "" {
            phoneLabel.hidden = false
        }
    }
    @IBAction func beginPass(sender: AnyObject) {
        passwordLab.hidden = true
    }
    @IBAction func endPass(sender: AnyObject) {
        if passwordSignUp.text == "" {
            self.passwordLab.hidden = false
        }
    }
    
    @IBAction func beginRe(sender: AnyObject) {
        repasswordLab.hidden = true
        
    }
    @IBAction func endRe(sender: AnyObject) {
        if returnPaswordSignUp.text == "" {
            self.repasswordLab.hidden = false
        }
    }
    
    @IBAction func beginEmail(sender: AnyObject) {
        userNameLab.hidden = true
        
    }
    
    @IBAction func endEmail(sender: AnyObject) {
        if emailSignUp.text == "" {
            self.userNameLab.hidden = false
        }
    }
    
    @IBAction func didEndRepass(sender: AnyObject) {
//        submit()
    }
}


