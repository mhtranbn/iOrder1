//
//  DetailCell3.swift
//  test
//
//  Created by mhtran on 5/24/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit

class DetailCell3: UITableViewCell {

    var selectionCallback: (() -> Void)?
    
    @IBOutlet weak var labelNumber: UILabel!
    var app : AppDelegate? = nil
    @IBOutlet weak var plus: UIButton!
    @IBOutlet weak var minus: UIButton!
    
    @IBOutlet weak var quantity: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        app = UIApplication.sharedApplication().delegate as? AppDelegate
        if quantity.text != "1" {
           
        }else if quantity == nil{
             quantity.text  = "1"
        }
        
        labelNumber.text = "Number".localized()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func plusAction(sender: AnyObject) {
        plus.setImage(UIImage(named: "numberredplus.png"), forState: UIControlState.Normal)
        delay(0.5) { 
            self.plus.setImage(UIImage(named: "Layer 32.png"), forState: UIControlState.Normal)
        }
        app?.number += 1
        quantity.text = String(app!.number)
        if let selectionCallback = self.selectionCallback {
            selectionCallback()
        }
    }
    @IBAction func minusAction(sender: AnyObject) {
        minus.setImage(UIImage(named: "numberred.png"), forState: UIControlState.Normal)
        delay(0.5) {
            self.minus.setImage(UIImage(named: "Layer 31.png"), forState: UIControlState.Normal)
        }

        if app?.number >= 2 {
            app?.number -= 1
            quantity.text = String(app!.number)
            if let selectionCallback = self.selectionCallback {
                selectionCallback()
            }
        }
        
    }
    
    //===========================================================
    
    
}
