//
//  HistoryCell.swift
//  iOrder
//
//  Created by mhtran on 5/19/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var date: UILabel!

    
    @IBOutlet weak var address: UILabel!
    
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
