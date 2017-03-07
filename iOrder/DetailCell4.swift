//
//  DetailCell4.swift
//  iOrder
//
//  Created by mhtran on 6/19/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit
import Money


class DetailCell4: UITableViewCell {

    @IBOutlet weak var check: SCheckBox!
    
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var total: UILabel!
    
    var selectionCallBack: (()-> Void)?
    var ratingCallBack: (()-> Void)?
    var orderCallBack: (()-> Void)?
    
    @IBOutlet weak var totalLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        let app = UIApplication.sharedApplication().delegate as? AppDelegate
        self.button.backgroundColor = app!.genererValue.colorMostOf
        self.check.color(UIColor.redColor(), forState: UIControlState.Normal)
        totalLabel.text = "Total:".localized()
        self.check.textLabel.text = "I want more...".localized()
        button.setTitle("Order Now".localized(), forState: .Normal)
        self.check.addTarget(self, action: #selector(DetailCell4.tapCheck(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.total.text = String(VND(minorUnits: (app!.priceItemsWithoutOption + app!.priceTotalOptions) * app!.number))
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func tapCheck(checkBox: SCheckBox!){
        print("\(checkBox.checked)")
        if checkBox.checked == true {
            button.setTitle("Add to List".localized(), forState: UIControlState.Normal)
        } else {
            button.setTitle("Order Now".localized(), forState: UIControlState.Normal)
        }
        if let selectionCallBack = self.selectionCallBack {
            selectionCallBack()
        }
    }
    
    @IBAction func orderAction(sender: AnyObject) {
        if let orderCallBack = self.orderCallBack {
            orderCallBack()
    
        }
    }
    

}
