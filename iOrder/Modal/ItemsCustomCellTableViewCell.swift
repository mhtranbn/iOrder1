//
//  ItemsCustomCellTableViewCell.swift
//  iOrder
//
//  Created by mhtran on 5/4/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import AlamofireImage


class ItemsCustomCellTableViewCell: UITableViewCell {
    @IBOutlet weak var itemsPrice: UILabel!
    var callBack:(()->Void)?
    @IBOutlet weak var quickBuy: MIBadgeButton!
    @IBOutlet weak var itemsImage: UIGradientImageView!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var countVote: UILabel!
    @IBOutlet weak var itemsName: UILabel!
    var flagCallback: Bool = false
    var countBagde:Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        quickBuy.setImage(UIImage(named: "quickOrder.png"),inFrame:CGRectMake(self.bounds.size.width - 80, 20, 60, 60), forState: UIControlState.Normal)
        rateButton.setImage(UIImage(named: "Layer 19 copy 4.png"), inFrame: CGRectMake(self.bounds.size.width - 78, self.bounds.size.height - 44, 20, 19), forState: UIControlState.Normal)
//        quickBuy.addTarget(self, action: #selector(ItemsCustomCellTableViewCell.quickOrderAction), forControlEvents: UIControlEvents.TouchUpInside)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if flagCallback == true {
            flagCallback = false
            if let callBack = self.callBack {
                callBack()
            }
        }
        // Configure the view for the selected state
    }
    @IBAction func quickOrderAction(sender: AnyObject) {
        if let callBack = self.callBack {
            callBack()
        }

    }
    
    @IBAction func addVote(sender: AnyObject) {
    }

    /*func showBagde(t:Int){
        if t > 0 {
            quickBuy.badgeString = "\(t)"
            quickBuy.badgeBackgroundColor = UIColor.redColor()
            quickBuy.badgeTextColor = UIColor.whiteColor()
            quickBuy.badgeEdgeInsets = UIEdgeInsetsMake(30, 0, 0, 30)
            //animate
            UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .CurveEaseOut, animations: {
                self.quickBuy.center.y -= 15
                }, completion: {finished in
                    UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseOut, animations: {
                        self.quickBuy.center.y += 15
                        },completion:{finished in
                    UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: { 
                        self.quickBuy.center.y -= 10
                        }, completion: {finished in
                            UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseOut, animations: { 
                                self.quickBuy.center.y += 10
                                }, completion: {finished in
                                    UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: { 
                                        self.quickBuy.center.y -= 5
                                        }, completion: {finished in
                                            UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseOut, animations: { 
                                                self.quickBuy.center.y += 5
                                                }, completion: nil)
                                    })
                            })
                    })
                    })})
        } else {
            quickBuy.badgeString = ""
            quickBuy.badgeBackgroundColor = UIColor.clearColor()
        }
        
    }*/

    deinit {
        print("Imte... deinit")
    }
}
