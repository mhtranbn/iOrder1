//
//  DetailHistoryCell1.swift
//  iOrder
//
//  Created by mhtran on 6/7/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit

class DetailHistoryCell1: UITableViewCell {

    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var website: UILabel!

    @IBOutlet weak var dateCell1: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
