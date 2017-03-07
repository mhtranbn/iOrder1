//
//  CustomNewBillCell.swift
//  iOrder
//
//  Created by mhtran on 5/29/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit

class CustomNewBillCell: UITableViewCell {

    @IBOutlet weak var stt: UILabel!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var price: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        

        // Configure the view for the selected state
    }

}
