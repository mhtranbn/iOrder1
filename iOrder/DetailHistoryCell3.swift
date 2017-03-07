//
//  DetailHistoryCell3.swift
//  iOrder
//
//  Created by mhtran on 6/7/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit

class DetailHistoryCell3: UITableViewCell {

    @IBOutlet weak var subTotalLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var subtotal: UILabel!
    
    @IBOutlet weak var tax: UILabel!
    
    @IBOutlet weak var total: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        subTotalLabel.text = "Sub Total".localized()
        taxLabel.text = "TAX".localized()
        totalLabel.text = "Total".localized()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
