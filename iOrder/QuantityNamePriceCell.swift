//
//  QuantityNamePriceCell.swift
//  iOrder
//
//  Created by mhtran on 6/8/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit

class QuantityNamePriceCell: UITableViewCell {

    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nameLabel.text = "Name".localized()
        quantityLabel.text = "Quantity".localized()
        priceLabel.text = "Price".localized()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
