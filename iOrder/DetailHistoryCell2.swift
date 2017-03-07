//
//  DetailHistoryCell2.swift
//  iOrder
//
//  Created by mhtran on 6/7/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit

class DetailHistoryCell2: UITableViewCell {

    
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        price.font = UIFont(name: "Helvetica Neue", size: 14)
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
