//
//  LoginVC.swift
//  LoginScreen
//
//  Created by mhtran on 4/15/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import SystemConfiguration
import Alamofire
import SwiftyJSON

//import GoogleSignIn

class LoginVC: UIViewController, UITextFieldDelegate,GIDSignInUIDelegate, GIDSignInDelegate {
    
    
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassw: UITextField!
    @IBOutlet weak var imageGradian1: UIGradientImageView2!
    @IBOutlet weak var imageGradian2: UIGradientImageView2!
    @IBOutlet weak var userNameLab: UILabel!
    @IBOutlet weak var passwordLab: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forgotPassLabel: UIButton!
    @IBOutlet weak var dontHaveAcountLabel: UILabel!
    @IBOutlet weak var sigUpLabel: UIButton!
    @IBOutlet weak var OrloginLabel: UILabel!
    let keychain = KeychainSwift()
    var indicator: UIActivityIndicatorView?
    let utility = Utility()
    let defaults = NSUserDefaults.standardUserDefaults()
    var app: AppDelegate? = nil
    var goDetail: Bool? = false
    var checkAddList: Bool? = false
    var mainStoryBoard : UIStoryboard!
    var mainPage : UIViewController!
    var mainPageNav : UINavigationController!
    override func viewDidLoad() {
        super.viewDidLoad()
        setText()
        backButton.setImage(
            UIImage(named: "arrow.png"),
            inFrame: CGRectMake(40, 40, 18, 18),
            forState: UIControlState.Normal
        )
        UITextField.connectFields([textFieldEmail,textFieldPassw])
        cornerImage()
        self.hidesBottomBarWhenPushed = true
        app = UIApplication.sharedApplication().delegate as? AppDelegate
        app?.viewDict["LoginVC"] = self
        mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        mainPage = mainStoryBoard.instantiateViewControllerWithIdentifier(SEGUE_CONTAINER) as! KYDrawerController
        mainPageNav = UINavigationController(rootViewController: mainPage)
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        if utility.checkNetworkConnectivity() {
        }
    }
    
    func setText() {
        buttonLogin.setTitle("Login".localized(), forState: .Normal)
        userNameLab.text = "Email".localized()
        passwordLab.text = "Password".localized()
        forgotPassLabel.setTitle("Forgot your password?".localized(), forState: .Normal)
        OrloginLabel.text = "Or login with".localized()
        dontHaveAcountLabel.text = "Don't have an account? ".localized()
        sigUpLabel.setTitle("Sign Up".localized(), forState: .Normal)
        textFieldPassw.delegate = self
        textFieldPassw.addTarget(self, action: #selector(LoginVC.textFieldShouldReturn(_:)), forControlEvents: UIControlEvents.EditingDidEndOnExit)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden =  true
        UIApplication.sharedApplication().statusBarHidden = true
        self.userNameLab.hidden = false
        self.passwordLab.hidden = false
    }
    
    //MARK: - GOOGLE_LOGIN
    
    @IBAction func signInwithGoogle(sender: AnyObject) {
        
        GIDSignIn.sharedInstance().signIn()
    }
    
    func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
    }
    
    func signIn(signIn: GIDSignIn!,
                dismissViewController viewController: UIViewController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signIn(signIn: GIDSignIn!,
                presentViewController viewController: UIViewController!) {
        self.presentViewController(viewController, animated: true, completion: nil)
    }

    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
                withError error: NSError!) {
        if (error == nil) {
            let accessToken = user.authentication.accessToken
            APIManager.loginSocialWithToken(accessToken,social:"google")
        }else {
            showAlert("No Network".localized(), message: "Please check again net work".localized())
            print("\(error.localizedDescription)")
            // [START_EXCLUDE silent]
            NSNotificationCenter.defaultCenter().postNotificationName(
                "ToggleAuthUINotification", object: nil, userInfo: nil)
            // [END_EXCLUDE]            
        }
    }

    // MARK: LOGIN FACEBOOK
    
    @IBAction func faceBookButtonPress(sender: AnyObject) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logInWithReadPermissions(["email"], fromViewController: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email")) {
                        self.getFBUserData()
                    FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
                        let accesssToken = FBSDKAccessToken.currentAccessToken().tokenString
                        // send token to server
                        APIManager.loginSocialWithToken(accesssToken,social: "facebook")
                    }
                }
                
            } else {
                self.removeFacebookData()
                self.showAlert("No Network".localized(), message: "Please check again network".localized())
            }
            if result.isCancelled {
            }
        }
    }
    
    func removeFacebookData() {
        let fbManager = FBSDKLoginManager()
        fbManager.logOut()
        FBSDKAccessToken.setCurrentAccessToken(nil)
    }
    
    func getFBUserData (){
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,interested_in,gender,birthday,email,age_range,name,picture.width(100).height(100)"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                let id : NSString = result.valueForKey("id") as! String
                print("User ID is: \(id)")
            }
        })
    }

    //MARK: LOGIN WITH EMAIL

    @IBAction func logInWithEmail(sender: AnyObject) {
        login()
    }
    
    func login() {
        if let email = textFieldEmail!.text where email != "", let pass = textFieldPassw!.text where pass != "" {
            APIManager.loginWithEmail(email, pass: pass)
            
        } else if textFieldEmail.text == "" || textFieldPassw.text == ""{
            showAlert("Error".localized(), message: "Cant empty field".localized())
        }else {
            showAlert("No Network".localized(), message: "Please check again net work".localized())
        }
    }
   
    //MARK: CONFIG
    func afterLogin(json:JSON) {
        guard json["status_code"].rawString()! == "null" else {
            var error: String = ""
            if json["errors"].rawString()! != "null" {
                for (_,subJson):(String,JSON) in (json["errors"].dictionary)! {
                    error = subJson[0].string!
                }
                self.showAlert("Error", message: "\(error)")
            } else {
                self.showAlert("Email or password wrong".localized(), message: "Please try again".localized())
            }
            self.view.endEditing(true)
            return
        }
        if json["meta"]["token"].rawString()! != "null" {
            self.keychain.set(json["meta"]["token"].rawString()!, forKey: TOKEN)
            Defaults[.login] = true
            APIManager.registerDeviceToServer()
            if self.goDetail == true{
                // from view Detail
                self.goDetail = false
                (app?.viewDict["KYDrawerController"] as! KYDrawerController).naviCustom.hidden = true
                if self.checkAddList == true {
                    self.checkAddList = false
                    (self.app?.viewDict["DetailItemVC"] as! DetailItemVC).check = true
                    (self.app?.viewDict["DetailItemVC"] as! DetailItemVC).orderItem()
                } else {
                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier(SEGUE_MYORDERVC) as! MyOrderVC
                    app?.viewDict["MyOrderVC"] = vc
                    (self.app?.viewDict["DetailItemVC"] as! DetailItemVC).orderItem()
                }
                if app?.flagsSearchVC == true {
                    app?.flagsSearchVC = false
                    mainPage = mainStoryBoard.instantiateViewControllerWithIdentifier(SEGUE_SEARCHCONTROLLER) as! SearchVC
                    mainPageNav = UINavigationController(rootViewController: mainPage)
                } else {
                    app?.flagJumpToMenuVC = true
                }
                app?.window?.rootViewController = mainPageNav
            }else {
                // cancel scan
                if Defaults["scan"].boolValue == true && app?.flagJumpToMenuVC != true{
                    app?.flagsBill = true
                } else {
                    if app?.flagsSearchVC == true {
                        app?.flagsSearchVC = false
                        mainPage = mainStoryBoard.instantiateViewControllerWithIdentifier(SEGUE_SEARCHCONTROLLER) as! SearchVC
                        mainPageNav = UINavigationController(rootViewController: mainPage)
                    } else {
                        app?.flagJumpToMenuVC = true
                    }
                }
                app?.window?.rootViewController = mainPageNav
            }
        } else {
            if json["errors"] != nil {
                for (_,subJson):(String,JSON) in (json["errors"].dictionary)! {
                    self.showAlert("\(subJson)".localized(), message: "Please try login".localized())
                }
            }
        }
    }
    
    func cornerImage() {
        imageGradian1.layer.masksToBounds = true
        imageGradian1.layer.cornerRadius = 8
        imageGradian2.layer.masksToBounds = true
        imageGradian2.layer.cornerRadius = 8
    }

    func authenticateWithGoogle(sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func signOut() {
        GIDSignIn.sharedInstance().signOut()
    }
    
    @IBAction func signUpEmail(sender: AnyObject) {
        self.navigationController?.pushViewController(({
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier(SEGUE_SIGN_UP) as! SignUpVC
            return vc
        })(), animated: true)
    }
    
    //MARK: RESET PASSWORD
    
    @IBAction func forgotPasswordAction(sender: AnyObject) {
        self.navigationController?.pushViewController({
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier(SEGUE_FORGOT_PASS) as! PasswordResetVC
            return vc
            }(), animated: false)
    }
    
    @IBAction func back(sender: AnyObject) {
        if Defaults["scan"].boolValue == true {
            Defaults[.scan] = false
            self.navigationController?.popViewControllerAnimated(false)
        } else {
            app?.flagJumpToMyOrderVC = false
            app?.flagsBill = false
            app?.flagJumpToMenuVC = true
            app?.window?.rootViewController = mainPageNav
        }

        }
    //MARK TEXT FIELD DELEGATE HANLDE
    @IBAction func emailFieldAction(sender: AnyObject) {
        userNameLab.hidden = true
        if textFieldPassw.text == "" {
            self.passwordLab.hidden = false
        }
    }
    
    @IBAction func emailFieldEnd(sender: AnyObject) {
        if textFieldEmail.text == "" {
            self.userNameLab.hidden = false
        }
    }

    @IBAction func passFieldAction(sender: AnyObject) {
        passwordLab.hidden = true
        if textFieldEmail.text == "" {
            self.userNameLab.hidden = false
        }
    }
    
    @IBAction func passFieldEnd(sender: AnyObject) {
        if textFieldPassw.text == "" {
            self.passwordLab.hidden = false
        }
        
    }
    
    func sendRequestLogin() {
        if let email = textFieldEmail!.text where email != "", let pass = textFieldPassw!.text where pass != "" {
            APIManager.loginWithEmail(email, pass: pass)
            
        } else if textFieldEmail.text == "" || textFieldPassw.text == ""{
            showAlert("Error".localized(), message: "Cant empty field".localized())
        }else {
            showAlert("No Network".localized(), message: "Please check again net work".localized())
        }

    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        sendRequestLogin()
        return true
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if app?.viewDict["KYDrawerController"] != nil {
            app?.navitabbar.hideNaviBarTabbar()
        }
    }

    func showAlert(title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let actionOK = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler:{ (UIAlertAction) in
            
        })
        alertView.addAction(actionOK)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        textFieldEmail.text = ""
        textFieldPassw.text = ""
    }
    
}
