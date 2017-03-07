//
//  OnboardingCollectionViewCell.swift
//  iOrder
//
//  Created by mhtran on 7/16/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit

class OnboardingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var onboardingTitle: UILabel!
    @IBOutlet weak var onboardingImage: UIImageView!
    @IBOutlet weak var onboardingText: UILabel!
    @IBOutlet weak var success: UIImageView!
    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var skipButton: UIButton!
    
    static let cellIdentifier = "onboardingCollectionViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        styleCell()
    }
    func styleCell() {
        onboardingTitle.textColor = UIColor.redColor()
        onboardingText.textColor = UIColor.redColor()
    }
    func parseData(data: AnyObject) {
        let title = data["title"] as! String
        let image = data["image"] as? String
        let textDetail = data["text"] as! String
        onboardingTitle.text = title.uppercaseString
        onboardingImage.image = UIImage(named: image!)
        onboardingText.text = textDetail        
    }


}
