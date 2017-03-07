//
//  PageViewCell.swift
//  iOrder
//
//  Created by mhtran on 7/10/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit

class PageViewCell: UITableViewCell,UIScrollViewDelegate {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    var arrayImageData : [String] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func showImage(){
        guard arrayImageData.count > 0 else {
            return
        }
        for i in 0...arrayImageData.count - 1 {
            let imageString = NSURL(string: "\(arrayImageData[i])")
            let dataImage = NSData(contentsOfURL: imageString!)
            let image = UIImage(data: dataImage!)!
            let imageView = UIImageView(image: image)
            imageView.frame = CGRectMake(CGFloat(i) * self.frame.width, 0, self.frame.width,self.frame.height)
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
            scrollView.addSubview(imageView)
            pageControl.numberOfPages = arrayImageData.count 
            if arrayImageData.count <= 1 {
                scrollView.delegate = nil
                scrollView.scrollEnabled = false
            } else {
                scrollView.delegate = self
                scrollView.scrollEnabled = true
                let contentOffSet = CGPoint(x:scrollView.contentOffset.x * 2, y: 0)
                scrollView.setContentOffset(contentOffSet, animated: true)
            }
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
    }
    
}
