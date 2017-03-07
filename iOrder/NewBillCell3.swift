//
//  NewBillCell3.swift
//  iOrder
//
//  Created by mhtran on 6/7/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NewBillCell3: UITableViewCell {

    var callBack: (() -> Void)?
    var callBackPay: (() -> Void)?
    
    @IBOutlet weak var sub: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var thankyouLabel: UILabel!
    @IBOutlet weak var paybuttoonLabel: UIButton!
    
    @IBOutlet weak var subTotal: UILabel!
    @IBOutlet weak var tax: UILabel!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var checkBox: SCheckBox!
    @IBOutlet weak var payButtonAction: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        sub.text = "Sub total".localized()
        taxLabel.text = "TAX".localized()
        totalLabel.text = "Total".localized()
        thankyouLabel.text = "Thank You".localized()
        paybuttoonLabel.setTitle("Pay".localized(), forState: .Normal)
        payButtonAction.backgroundColor = app.genererValue.colorMostOf
        self.checkBox.textLabel.text = "I want to Pay...".localized()
        self.checkBox.addTarget(self, action: #selector(NewBillCell3.tapCheck(_:)), forControlEvents: UIControlEvents.ValueChanged)
        payButtonAction.titleLabel?.text = "Pay"
        
        if let callBack = self.callBack {
            callBack()
        }
        
    }

    func tapCheck(checkBox: SCheckBox!){

        
        print("fasdfsdfsdfdsf\(checkBox.checked)")
        if payButtonAction.titleLabel?.text == "Pay".localized() {
            payButtonAction.setTitle("Pay to All".localized(), forState: UIControlState.Normal)
            
            
        } else {
            payButtonAction.setTitle("Pay".localized(), forState: UIControlState.Normal)
            
        }
        if let callBack = self.callBack {
            callBack()
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func PayAction(sender: AnyObject) {

        if let callBackPay = self.callBackPay {
            callBackPay()
        }
        
    }
}
