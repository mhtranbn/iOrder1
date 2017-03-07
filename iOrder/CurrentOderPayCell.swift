//
//  CurrentOderPayCell.swift
//  iOrder
//
//  Created by mhtran on 6/5/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit

class CurrentOderPayCell: UITableViewCell {
    
    
    @IBOutlet weak var tatalLabel: UILabel!
    
    
    @IBOutlet weak var noteLabel: UILabel!
    
    @IBOutlet weak var miniumlabel: UILabel!
    
    @IBOutlet weak var freeshipLabel: UILabel!
    
    @IBOutlet weak var total: UILabel!
    
    @IBOutlet weak var minium: UILabel!

    @IBOutlet weak var shipType: UILabel!
    
    @IBOutlet weak var buttonPay: UIButton!
    
    @IBOutlet weak var orderButton: UIButton!
    var callBack: (() ->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        buttonPay.backgroundColor = app.genererValue.colorMostOf
        tatalLabel.text = "Total:".localized()
        noteLabel.text = "Note:".localized()
        miniumlabel.text = "Minium Order   100000 VND".localized()
        freeshipLabel.text = "Free ship".localized()
        orderButton.setTitle("Order Now".localized(), forState: .Normal)
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
        // Configure the view for the selected state
    }
    
    @IBAction func orderAction(sender: AnyObject) {
        if let callBack = self.callBack {
            callBack()
        }
        
    }
    
    
}
