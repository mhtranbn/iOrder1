//
//  CurrentOrderNewBillCell.swift
//  iOrder
//
//  Created by mhtran on 6/5/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit

class CurrentOrderNewBillCell: UITableViewCell {
    
    var callBack: (() ->Void)?

    @IBOutlet weak var imageItems: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var quantity: UILabel!
    
    @IBOutlet weak var price: UILabel!

    @IBOutlet weak var textView: UITextView!
    
    override func layoutSubviews() {

        super.layoutSubviews()
        textView.scrollRangeToVisible(NSMakeRange(0, 0))
        for subview in self.subviews {
            for subview2 in subview.subviews {
                if (String(subview2).rangeOfString("UITableViewCellActionButton") != nil) {
                    if let button = subview2 as? UIButton { button.setTitleColor(UIColor.redColor(), forState: .Normal) }
                }
            }
        }
        
    }
    
//    func viewWillAppear(animated: Bool) {
//        textView.scrollEnabled = false
//    }
//    
//    func viewDidAppear(animated: Bool) {
//        textView.scrollEnabled = true
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let callBack = self.callBack {
            callBack()
        }

        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    }
