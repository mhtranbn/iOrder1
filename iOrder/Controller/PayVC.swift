//
//  PayVC.swift
//  iOrder
//
//  Created by mhtran on 6/12/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
//import Stripe

class PayVC: UIViewController, SSRadioButtonControllerDelegate {
    
    @IBOutlet weak var cardNumber: AkiraTextField!
    @IBOutlet weak var Exp: AkiraTextField!
    @IBOutlet weak var expYear: AkiraTextField!
    @IBOutlet weak var expCVV: AkiraTextField!
    @IBOutlet weak var backButton: UIButton!
    var billId: String = ""
    @IBOutlet weak var navicustom: UIView!
    @IBOutlet weak var payLabel: UILabel!
    
    @IBOutlet weak var paymentLaybel: UILabel!
    
    @IBOutlet weak var LoremLabel: UILabel!
    
    @IBOutlet weak var cashLabel: UIButton!
    @IBOutlet weak var confirmLabel: UIButton!
//    var braintreeClient: BTAPIClient?
    @IBOutlet weak var button1: SSRadioButton!
    @IBOutlet weak var button2: SSRadioButton!
    @IBOutlet weak var button3: SSRadioButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        var radioButtonController: SSRadioButtonsController?
        radioButtonController = SSRadioButtonsController(buttons: button1, button2, button3)
        radioButtonController!.delegate = self
        radioButtonController!.shouldLetDeSelect = true
        app.viewDict["PayVC"] = self
        setText()
        navicustom.backgroundColor = app.genererValue.color
        backButton.setImage(
            UIImage(named: "arrow.png"),
            inFrame: CGRectMake(10, 30, 18, 18),
            forState: UIControlState.Normal
        )
        
        //set up BrainTrePayment
        
         /*
         let clientTokenURL = NSURL(string: "https://braintree-sample-merchant.herokuapp.com/client_token")!
         let clientTokenRequest = NSMutableURLRequest(URL: clientTokenURL)
         clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
         
         NSURLSession.sharedSession().dataTaskWithRequest(clientTokenRequest) { (data, response, error) -> Void in
         // TODO: Handle errors
         let clientToken = String(data: data!, encoding: NSUTF8StringEncoding)
         
         self.braintreeClient = BTAPIClient(authorization: clientToken!)
         // As an example, you may wish to present our Drop-in UI at this point.
         // Continue to the next section to learn more...
         }.resume()
         
         let clientToken = "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiJmNjIyMmU3OTAzYjJmZGE0MGU0M2Q1MGZlZWQ2MmFjZTA5ZDZkNTdjYWRmZGE5YzZkMjUyZjJiNWE0NTNkZDA3fGNyZWF0ZWRfYXQ9MjAxNi0wNy0wOFQwOToxNDoyOC43NjIzMDc0MzArMDAwMFx1MDAyNm1lcmNoYW50X2lkPTM0OHBrOWNnZjNiZ3l3MmJcdTAwMjZwdWJsaWNfa2V5PTJuMjQ3ZHY4OWJxOXZtcHIiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvMzQ4cGs5Y2dmM2JneXcyYi9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJjaGFsbGVuZ2VzIjpbXSwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzLzM0OHBrOWNnZjNiZ3l3MmIvY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBzOi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vY2xpZW50LWFuYWx5dGljcy5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tLzM0OHBrOWNnZjNiZ3l3MmIifSwidGhyZWVEU2VjdXJlRW5hYmxlZCI6dHJ1ZSwicGF5cGFsRW5hYmxlZCI6dHJ1ZSwicGF5cGFsIjp7ImRpc3BsYXlOYW1lIjoiQWNtZSBXaWRnZXRzLCBMdGQuIChTYW5kYm94KSIsImNsaWVudElkIjpudWxsLCJwcml2YWN5VXJsIjoiaHR0cDovL2V4YW1wbGUuY29tL3BwIiwidXNlckFncmVlbWVudFVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS90b3MiLCJiYXNlVXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhc3NldHNVcmwiOiJodHRwczovL2NoZWNrb3V0LnBheXBhbC5jb20iLCJkaXJlY3RCYXNlVXJsIjpudWxsLCJhbGxvd0h0dHAiOnRydWUsImVudmlyb25tZW50Tm9OZXR3b3JrIjp0cnVlLCJlbnZpcm9ubWVudCI6Im9mZmxpbmUiLCJ1bnZldHRlZE1lcmNoYW50IjpmYWxzZSwiYnJhaW50cmVlQ2xpZW50SWQiOiJtYXN0ZXJjbGllbnQzIiwiYmlsbGluZ0FncmVlbWVudHNFbmFibGVkIjp0cnVlLCJtZXJjaGFudEFjY291bnRJZCI6ImFjbWV3aWRnZXRzbHRkc2FuZGJveCIsImN1cnJlbmN5SXNvQ29kZSI6IlVTRCJ9LCJjb2luYmFzZUVuYWJsZWQiOmZhbHNlLCJtZXJjaGFudElkIjoiMzQ4cGs5Y2dmM2JneXcyYiIsInZlbm1vIjoib2ZmIn0="
         }
         
         */
    }
    
    func didSelectButton(aButton: UIButton?) {
        print(aButton!)
        if aButton == button1 {
            
        }
    }
         func setText() {
         payLabel.text = "Pay".localized()
         payLabel.text = "PAYMENT METHOD".localized()
         LoremLabel.text = "Lorem Ipsum is simply dummy text of the printting and typesetting insustry".localized()
         cashLabel.setTitle("Cash".localized(), forState: .Normal)
         confirmLabel.setTitle("Confirm".localized(), forState: .Normal)
         cardNumber.placeholder = "Card Number".localized()
         Exp.placeholder = "Exp. Month".localized()
         expYear.placeholder = "Exp. Year".localized()
         expCVV.placeholder = "CVV".localized()
         
         }
 
    
    func sendServerIdBill(billID: String) {
        let para = ["transaction": "123456789",]
        APIManager.confirmPay(billID, params: para) { (error) in
            self.showAlert("Error".localized(), message: "\(error)")
            self.view.endEditing(true)
        }
    }
    func showAlert(title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let actionOK = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler:{ (UIAlertAction) in
            
        })
        alertView.addAction(actionOK)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    @IBAction func cash(sender: AnyObject) {
        jumptoHistoryVC()
    }
    
    func jumptoHistoryVC() {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("RAMAnimatedTabBarController") as! RAMAnimatedTabBarController
        self.navigationController?.pushViewController({
            let app = UIApplication.sharedApplication().delegate as! AppDelegate
            vc.animationTabBarHidden(false)
            vc.setSelectIndex(from: 3, to: 3)
            (app.viewDict["ContainerBillVC"] as! ContainerBillVC).swipeableView.jumpToCurrentOrderView()
            return vc
            }(), animated: false)        
    }
    
    @IBAction func confirmAction(sender: AnyObject) {
        
        sendServerIdBill(billId)
        jumptoHistoryVC()
        
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }

    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBarHidden = true
        let app = UIApplication.sharedApplication().delegate as? AppDelegate
        app?.navitabbar.hideNaviBarTabbar()
        UIApplication.sharedApplication().statusBarHidden = true
        showStatusBar()

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    /*
     func dropInViewController(viewController: BTDropInViewController, didSucceedWithTokenization paymentMethodNonce: BTPaymentMethodNonce) {
     // ...
     // Send payment method nonce to your server for processing
     postNonceToServer(paymentMethodNonce.nonce)
     dismissViewControllerAnimated(true, completion: nil)
     }
     
     func dropInViewControllerDidCancel(viewController: BTDropInViewController) {
     // ...
     dismissViewControllerAnimated(true, completion: nil)
     }
     */
    
    /*
     func tappedMyPayButton() {
     
     // If you haven't already, create and retain a `BTAPIClient` instance with a
     // tokenization key OR a client token from your server.
     // Typically, you only need to do this once per session.
     // braintreeClient = BTAPIClient(authorization: CLIENT_AUTHORIZATION)
     
     // Create a BTDropInViewController
     let dropInViewController = BTDropInViewController(APIClient: braintreeClient!)
     dropInViewController.delegate = self
     
     // This is where you might want to customize your view controller (see below)
     
     // The way you present your BTDropInViewController instance is up to you.
     // In this example, we wrap it in a new, modally-presented navigation controller:
     dropInViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
     barButtonSystemItem: UIBarButtonSystemItem.Cancel,
     target: self, action: #selector(MyViewController.userDidCancelPayment))
     let navigationController = UINavigationController(rootViewController: dropInViewController)
     presentViewController(navigationController, animated: true, completion: nil)
     }
     
     func userDidCancelPayment() {
     dismissViewControllerAnimated(true, completion: nil)
     }

     */
/*
     func paymentContextDidChange(paymentContext: STPPaymentContext) {
     self.activityIndicator.animating = paymentContext.loading
     self.paymentButton.enabled = paymentContext.selectedPaymentMethod != nil
     self.paymentLabel.text = paymentContext.selectedPaymentMethod?.label
     self.paymentIcon.image = paymentContext.selectedPaymentMethod?.image
     }
     
     func paymentContext(paymentContext: STPPaymentContext,
     didCreatePaymentResult paymentResult: STPPaymentResult,
     completion: STPErrorBlock) {
     
     myAPIClient.createCharge(paymentResult.source.stripeID, completion: { (error: NSError?) in
     if let error = error {
     completion(error)
     } else {
     completion(nil)
     }
     })
     
     }
     
     func paymentContext(paymentContext: STPPaymentContext,
     didFinishWithStatus status: STPPaymentStatus,
     error: NSError?) {
     
     switch status {
     case .Error:
     self.showError(error)
     case .Success:
     self.showReceipt()
     case .UserCancellation:
     return // do nothing
     }
     
     }
     */
    
    
}
