//
//  PreferencesCell.swift
//  iOrder
//
//  Created by mhtran on 7/10/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit
import Cosmos

class PreferencesCell: UITableViewCell {
    var ratingCallBack: ((check:Int,rating:Double)-> Void)?
    @IBOutlet weak var descriptionItem: UILabel!
    
    @IBOutlet weak var rate: CosmosView!
    
    @IBOutlet weak var preferencesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        preferencesLabel.text = "Preferences".localized()
        rate.didTouchCosmos = didTouchcomos
        rate.didFinishTouchingCosmos = didFinishTouchingCosmos
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    func rateDetail() {
//        rate.didFinishTouchingCosmos = { rating in
//
//        }
//        // A closure that is called when user changes the rating by touching the view.
//        // This can be used to update UI as the rating is being changed by moving a finger.
//        rate.didTouchCosmos = { rating in
//        
//            print("rating")
//        }
//    }
    
    func upDateRating(value:Double){
        NSLog("-------log here \(NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate: NSDate()).minute) please see it----= \(value)")
        rate.rating = value
    }
    
    func didTouchcomos(rating:Double) {
        ratingCallBack!(check: 1,rating: rating)
    }
    
    func didFinishTouchingCosmos(rating:Double) {
        ratingCallBack!(check: 0,rating: rating)
    }

    
}
