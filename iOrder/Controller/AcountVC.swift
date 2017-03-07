//
//  AcountVC.swift
//  iOrder
//
//  Created by mhtran on 6/14/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import AlamofireImage
import SwiftyJSON
import Kingfisher
import UIKit.UIGestureRecognizerSubclass

class AcountVC: UIViewController,NSFetchedResultsControllerDelegate,UITextFieldDelegate {

    var app: AppDelegate? = nil
    
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var imageAvata: UIImageView!
    @IBOutlet weak var profileView: UIView!
    
    @IBOutlet weak var changeImage: UIButton!

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    
    @IBOutlet weak var buttonEdit: UIButton!
    @IBOutlet weak var editBackground: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
   

    var result: NSFetchedResultsController!
    var editBool: Bool = false
    var firstServiceCallComplete = false
    var secondServiceCallComplete = false
    var croppingEnabled: Bool = true
    var libraryEnabled: Bool = true
    var callBack:(()-> Void)?
    var keychain = KeychainSwift()
    var user: UserClass!
    var heightKeyboard: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        app = UIApplication.sharedApplication().delegate as? AppDelegate
        app?.viewDict["AcountVC"] = self
        getDataUser()
        setupUI()
        UITextField.connectFields([name,email,phone])
    }
    
    @objc private func keyboardWillShow(notification:NSNotification) {
        
        let userInfo:NSDictionary = notification.userInfo!
        let keyboardFrame:NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.CGRectValue()
        let keyboardHeight = keyboardRectangle.height
        heightKeyboard = keyboardHeight
    }
    
    
    func setData() {
        guard result != nil else {
            return
        }
    }
    
    func setupUI(){
        profileView.backgroundColor = app?.genererValue.color
        editBackground.backgroundColor = app?.genererValue.colorMostOf
        profileLabel.text = "PROFILE".localized()
        backButton.setImage(
            UIImage(named: "arrow.png"),
            inFrame: CGRectMake(10, 8, 18, 18),
            forState: UIControlState.Normal
        )
        
        changeModeEditTextField(false)
        let origImage = UIImage(named: "Layer 26.png")
        let tintedImage = origImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    changeImage.setImage(tintedImage,
                             inFrame: CGRectMake(imageAvata.center.x - 25,
                                imageAvata.center.y - 25, 49, 38), forState: UIControlState.Normal)
        changeImage.hidden = true
        changeImage.tintColor = UIColor.whiteColor()
        imageAvata.layer.masksToBounds = true
        imageAvata.layer.cornerRadius = imageAvata.bounds.size.width / 2
        imageAvata.layer.borderWidth = 3
        imageAvata.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    func changeModeEditTextField(activity: Bool) {
        name.userInteractionEnabled = activity
        email.userInteractionEnabled = activity
        phone.userInteractionEnabled = activity
    }
    
    func fillData() {
        name.attributedPlaceholder = NSAttributedString(string: "Name".localized(), attributes: [NSForegroundColorAttributeName :UIColor.whiteColor()])
        email.attributedPlaceholder = NSAttributedString(string: "Email".localized(), attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        phone.attributedPlaceholder = NSAttributedString(string: "Phone".localized(), attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        name.text = self.user.name
        email.text = self.user.email
        if let phoneUser:String = user.phone {
            phone.text = phoneUser
        }
        let url = NSURL(string: user.avatar)
        let resource = Resource(downloadURL: url!)
        imageAvata.kf_setImageWithResource(resource)
        phone.delegate = self
        phone.addTarget(self, action: #selector(AcountVC.textFieldShouldReturn(_:)), forControlEvents: UIControlEvents.EditingDidEndOnExit)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        sendDataToServer()
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        showStatusBar()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = true
        UIApplication.sharedApplication().statusBarHidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        buttonEdit.setImage(UIImage(named: "editImage.png"),inFrame: CGRectMake(self.view.bounds.size.width - 50, 8, 30,30), forState: .Normal)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    @IBAction func editAcount(sender: AnyObject) {
        if editBool == false {
            changeImage.hidden = false
            editBool = true
            profileLabel.text = "EDIT PROFILE".localized()
            buttonEdit.setTitle("Done".localized(), forState: UIControlState.Normal)
            let boldHelveticaFont = UIFont(name: "Helvetica Neue", size: 17)?.fontDescriptor().fontDescriptorWithSymbolicTraits(UIFontDescriptorSymbolicTraits.TraitBold)
            buttonEdit.titleLabel?.font = UIFont(descriptor: boldHelveticaFont!, size: 17)
            buttonEdit.setImage(UIImage(named: ""),inFrame: CGRectMake(self.view.bounds.size.width - 50, 8, 30,30), forState: .Normal)
            changeModeEditTextField(true)
        } else {
            changeImage.hidden = true
            editBool = false
            profileLabel.text = "PROFILE".localized()
            buttonEdit.setImage(UIImage(named: "editImage.png"),inFrame: CGRectMake(self.view.bounds.size.width - 50, 8, 30,30), forState: .Normal)
            buttonEdit.setTitle("", forState: UIControlState.Normal)
            changeModeEditTextField(false)
            imageAvata.image = imageAvata.image?.resizeUnder(0.1)
            sendDataToServer()
            scrollView.contentOffset = CGPointMake(0.0, 0)
        }
        
    }
    func showAlert(title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let actionOK = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler:{ (UIAlertAction) in
        })
        alertView.addAction(actionOK)
        self.presentViewController(alertView, animated: true, completion: nil)
    }

    func sendDataToServer() {
        let token = keychain.get(TOKEN)!
        let para = [ "email" : email.text!,
                     "name" : name.text!,
                     "phone": phone.text!,
                     "_method" : "put",
        ]
        APIManager.updateAcount(token,params:para, imgage: self.imageAvata) { (check, json) in
            if check == 1 {
                guard json["errors"] == nil else {
                    var error: String = ""
                    for (_,subJson):(String,JSON) in (json["errors"].dictionary)! {
                        error = subJson[0].string!
                        self.showAlert("Error".localized(), message: error)
                    }
                    self.getDataUser()
                    return
                }
                self.user = nil
                self.user = UserClass.parser(json)
                self.fillData()
            } else if check == 2 {
                self.showAlert("Failure".localized(), message: "failure to requset server".localized())
            }
        }
    }
    
    func getDataUser() {
        APIManager.getAcount(KeychainSwift().get(TOKEN)!) { (json) in
            self.user = nil
            self.user = UserClass.parser(json)
            self.fillData()
        }
    }
 
    @IBAction func changeAvata(sender: AnyObject) {
        let cameraViewController = CameraViewController(croppingEnabled: croppingEnabled, allowsLibraryAccess: libraryEnabled) { [weak self] image, asset in
            self?.imageAvata.image = image
//            self?.imageAvata.image = self?.imageAvata.image.resizeUnder(0.1)
            self?.dismissViewControllerAnimated(true, completion: {
//                self?.changeImage.hidden = true
                self?.buttonEdit
                self?.buttonEdit.setTitle("Done".localized(), forState: .Normal)
                self!.buttonEdit.setImage(UIImage(named: ""),inFrame: CGRectMake(self!.view.bounds.size.width - 50, 8, 30,30), forState: .Normal)
            })
        }
        presentViewController(cameraViewController, animated: true, completion: nil)
        cameraViewController.closeButton.addTarget(self, action: #selector(AcountVC.returnImage), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    
    @IBAction func didBeginPhone(sender: AnyObject) {
        scrollView.contentOffset = CGPointMake(0.0, 70)
    }
    
    func returnImage() {
        let url = NSURL(string: user.avatar)
        let resource = Resource(downloadURL: url!)
        imageAvata.kf_setImageWithResource(resource)
    }

    
    // MARK: Configuration Picker Camera
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }

}
