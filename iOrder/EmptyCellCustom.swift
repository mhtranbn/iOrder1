//
//  EmptyCellCustom.swift
//  iOrder
//
//  Created by mhtran on 6/14/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit

class EmptyCellCustom: UITableViewCell {

    @IBOutlet weak var emptyLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        emptyLabel.text = "Opps!, No thing, please Order :)".localized()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
