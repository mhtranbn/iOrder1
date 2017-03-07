//
//  DetailCell2.swift
//  test
//
//  Created by mhtran on 5/24/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit
import CoreData

class DetailCell2: UITableViewCell {

    var selectionCallback: (() -> Void)?
    var bool: Bool = false
    var totalPriceForOption: Int = 0
    var total:Int = 0
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var price: UILabel!
    

    @IBOutlet weak var switchSelect: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func switchAction(sender: AnyObject) {
 
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        bool = !bool
        if bool == true {
            
            switchSelect.setImage(UIImage(named: "buttonSwitch1.png"), forState: UIControlState.Normal)
            app.priceTotalOptions += totalPriceForOption
            if let selectionCallback = self.selectionCallback{
                selectionCallback()
            }
            
        } else if bool == false {
            switchSelect.setImage(UIImage(named: "buttonSwitch2.png"), forState: UIControlState.Normal)
            app.priceTotalOptions -= totalPriceForOption
            if let selectionCallback = self.selectionCallback{
                selectionCallback()
            }
        }
    }

}
