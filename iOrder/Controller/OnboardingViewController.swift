//
//  OnboardingViewController.swift
//  iOrder
//
//  Created by mhtran on 7/16/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController ,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    @IBOutlet weak var onboardingCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var startButton: UIButton!
    var onboardingViewData: [[String:AnyObject]] = []
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let backgroundColor = CAGradientLayer().mainGardient()
        backgroundColor.frame = self.view.bounds
        self.view.layer.insertSublayer(backgroundColor, atIndex: 0)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        startButton.alpha = 0;
        startButton.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
        UIApplication.sharedApplication().statusBarHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        onboardingCollectionView.backgroundColor = UIColor.clearColor()
        onboardingCollectionView.dataSource = self
        onboardingCollectionView.delegate = self
        onboardingCollectionView.showsHorizontalScrollIndicator = false
        onboardingCollectionView.pagingEnabled = true
        onboardingCollectionView.bounces = false
        onboardingViewData = onboardingData
        
        styleView()
    }
    
    func styleView() {
        
        pageControl.numberOfPages = onboardingViewData.count
        pageControl.pageIndicatorTintColor = UIColorFromRGBA("2F3043", alpha: 0.5)
        startButton.addTarget(self, action: #selector(OnboardingViewController.startAdventure(_:)), forControlEvents: .TouchUpInside)
        
    }
    
    func startAdventure(sender: UIButton) {
        
        let vc = storyboard?.instantiateViewControllerWithIdentifier("xxx")
        self.presentViewController(vc!, animated: true, completion: nil)
        LocalStore.isFirstTime(true)
        
    }
    
    func hideStartButton(alpha: CGFloat, enabled: Bool) {
        UIView.animateWithDuration(0.5) { () -> Void in
            self.startButton.alpha = alpha
            self.startButton.enabled = enabled
        }
    }

    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        let pageWidth = CGRectGetWidth(scrollView.frame)
        let currentPage = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        
        pageControl.currentPage = Int(currentPage)
        
        if currentPage == 3 {
            hideStartButton(1.0, enabled: true)
        }else{
            hideStartButton(0, enabled: false)
        }
        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return onboardingViewData.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(OnboardingCollectionViewCell.cellIdentifier, forIndexPath: indexPath) as! OnboardingCollectionViewCell
        let data = onboardingViewData[indexPath.row]
        cell.parseData(data)
        cell.backgroundColor = UIColor.clearColor()
        cell.onboardingText.textColor = UIColor.redColor()
        if indexPath.row == onboardingViewData.count - 1 {
            cell.onboardingText.textColor = UIColor.whiteColor()
        }
        return cell
    }
}
