//
//  DownLoadImage.swift
//  iOrder
//
//  Created by mhtran on 6/10/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import Foundation
class DownloadImage {
    
    class func downloadImages(URL: String) -> UIImage! {
        
        let image = NSData(contentsOfURL: NSURL(string: URL)!)
        //print(image)
        return UIImage(data: image!)
        
    }
}