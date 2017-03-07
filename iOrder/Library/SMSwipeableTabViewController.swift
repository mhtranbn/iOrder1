//
//  SMSwipeableTabViewController.swift
//  SMSwipeableTabView
//
//  Created by Sahil Mahajan on 21/12/15.
//  Copyright © 2015 Sahil Mahajan. All rights reserved.
//

import UIKit


/// Attribute Dictionary Keys. These keys are used to customize the UI elements of View.

/**
 Take UIFont as value. Set font of Tab button titleLabel Font.
 */
public let SMFontAttribute = "kFontAttribute"

/**
 Take UIColor as value. Set color of Tab button titleLabel Font.
 */
public let SMForegroundColorAttribute = "kForegroundColorAttribute"

/**
 Take UIColor as value. Set background color of any View.
 */
public let SMBackgroundColorAttribute = "kBackgroundColorAttribute"

/// Take CGFlaot as value. Set alpha of any View.
public let SMAlphaAttribute = "kAlphaAttribute"

/// Take UIImage as value. Set image of any View.
public let SMBackgroundImageAttribute = "kBackgroundImageAttribute"

/// Take Array of Strings(image_name) as value. Set button image for normal state.
public let SMButtonNormalImagesAttribute = "kButtonNormalImageAttribute"

/// Take Array of Strings(image_name) as value. Set button image for highlighted state.
public let SMButtonHighlightedImagesAttribute = "kButtonHighlightedImageAttribute"

/// Take Bool as value. Set title label of tab bar button hidden.
public let SMButtonHideTitleAttribute = "kButtonShowTitleAttribute" // Set Bool instance

/// Swipe constant
public let kSelectionBarSwipeConstant: CGFloat = 3.0

var tagFake:NSNumber = 1

public protocol SMSwipeableTabViewControllerDelegate {
    func didLoadViewControllerAtIndex(index: Int) -> UIViewController
}

public class SMSwipeableTabViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {
    
    //flag disable swipe
    
    public var disableSwipe: Bool = false
    
    /// To set the height of segment bar(Top swipable tab bar).
    public var segementBarHeight: CGFloat = 50.0
    
    /// To set the margin beteen the buttons or tabs in the scrollable tab bar
    public var buttonPadding: CGFloat = 25.0
    
    /// To set the fixed width of the button/tab in the tab bar
    public var buttonWidth: CGFloat = 0.0
    
    /** To set the height of the selection bar
     Selection bar can be seen under the tab
     */
    public var selectionBarHeight: CGFloat = 0.0
    
    /** To set the background color of the tab bar.
     Default color is blue color. You can change the color as per your need.
     */
    public let defaultSegmentBarBgColor = UIColor.whiteColor()
    
    /** To set the background color of the selection bar.
     Default color is red color. You can change the color as per your need.
     */
    public let defaultSelectionBarBgColor = UIColor.redColor()
    
    ///Dictionary to set button attributes. User can change the titleFont, titleFontColor, Normal Image, Selected Image etc.
    /**
     - Usage:
     buttonAttributes = [
     SMBackgroundColorAttribute : UIColor.clearColor(),
     SMAlphaAttribute : 0.8,
     SMButtonHideTitleAttribute : true,
     SMButtonNormalImagesAttribute :["image_name1", "image_name2"] as [String]),
     SMButtonHighlightedImagesAttribute : ["high_image_name1", "high_image_name2"] as [String])
     ]
     */
    public var buttonAttributes: [String : AnyObject]?
    
    ///Dictionary to set tab bar attributes. User can change the titleFont, titleFontColor, Normal Image, Selected Image etc.
    /**
     - Usage:
     segmentBarAttributes = [
     SMBackgroundColorAttribute : UIColor.greenColor(),
     ]
     */
    public var segmentBarAttributes: [String : AnyObject]?
    ///Dictionary to selection bar attributes. User can change the titleFont, titleFontColor, Normal Image, Selected Image etc.
    /**
     - Usage:
     segmentBarAttributes = [
     SMBackgroundColorAttribute : UIColor.greenColor(),
     SMAlphaAttribute : 0.8
     ]
     */
    public var selectionBarAttributes: [String : AnyObject]?
    /// To set the frame of the view.
    public var viewFrame : CGRect?
    /// Array of tab Bar Buttons (Text need to display)
    public var titleBarDataSource: [String]?
    /// Delegate of viewController. Set the delegate to load the viewController at new index.
    public var delegate: SMSwipeableTabViewControllerDelegate?
    public var pageViewController: UIPageViewController?
    //Fixed
    private lazy var segmentBarView = UIScrollView()
    private lazy var selectionBar = UIView()
    private var buttonsFrameArray = [CGRect]()
    var frameButtonCenterArray = [CGRect]()
    var flagCenter:Bool = false
    var flagFirstLoad: Bool = true
    private var buttonWidthArray = [CGFloat]()
    public var currentPageIndex = 0
    private let contentSizeOffset: CGFloat = 80.0
    private var pageScrollView: UIScrollView?
    private var c : [UIButton] = []
    var app: AppDelegate? = nil
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        app = UIApplication.sharedApplication().delegate as? AppDelegate
        buttonAttributes = [
            SMBackgroundColorAttribute : UIColor.whiteColor(),
            SMAlphaAttribute : 1.0,
            SMFontAttribute : UIFont(name: "HelveticaNeue-Medium", size: 15.0)!,
            SMForegroundColorAttribute : UIColor.grayColor(),
            SMButtonHighlightedImagesAttribute: true
        ]
        if flagCenter == false {
            buttonWidth = getMaxWidthString(titleBarDataSource!)
            
        } else {
            buttonWidth = self.view.frame.width / 2
        }
        for i in c {
            i.sizeToFit()
            i.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 60)
            i.titleLabel?.numberOfLines = 0
            i.titleLabel?.minimumScaleFactor = 0.1
            i.titleLabel?.baselineAdjustment = .AlignCenters
            i.titleLabel?.textAlignment = NSTextAlignment.Center
        }
        if let frame = viewFrame {
            self.view.frame = frame
        }
        self.pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        if let startingViewController = viewControllerAtIndex(currentPageIndex) {
            let viewControllers = [startingViewController]
            self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: {done in })
            self.pageViewController!.dataSource = self
            self.pageViewController?.delegate = self
            self.addChildViewController(self.pageViewController!)
            self.view.addSubview(self.pageViewController!.view)
            let pageViewRect = CGRectMake(0.0, segementBarHeight + 60, self.view.frame.width, self.view.frame.height-segementBarHeight - 60)
            self.pageViewController!.view.frame = pageViewRect
            self.pageViewController!.didMoveToParentViewController(self)
            if disableSwipe == true {
                for view in self.pageViewController!.view.subviews {
                    if let subView = view as? UIScrollView {
                        subView.scrollEnabled = false
                    }
                }
            }
            // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
            self.view.gestureRecognizers = self.pageViewController!.gestureRecognizers
        }
        syncScrollView()
        setupSegmentBar()
        if c.count > 0 {
            c[currentPageIndex].setTitleColor(UIColor.redColor(), forState: .Normal)
        }
    }
    
    func getMaxWidthString(arrayString:[String]) -> CGFloat {
        var result: CGFloat = 0
        for i in arrayString {
            let textSize = i.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(15.0)]).width
            if textSize > result{result = textSize}
        }
        return result
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        app?.navitabbar.showNaviTabBar()
    }
    
    private func setupSegmentBar() {
        segmentBarView.frame = CGRectMake(0.0, 60, UIScreen.mainScreen().bounds.width, segementBarHeight )
        segmentBarView.scrollEnabled = true
        segmentBarView.showsHorizontalScrollIndicator = false
        segmentBarView.backgroundColor = defaultSegmentBarBgColor
        if let attributes = segmentBarAttributes {
            if let bgColor = attributes[SMBackgroundColorAttribute] as? UIColor {
                segmentBarView.backgroundColor = bgColor
            }
            if let bgImage = attributes[SMBackgroundImageAttribute] as? UIImage {
                segmentBarView.backgroundColor = UIColor(patternImage: bgImage)
            }
        }
        setupSegmentBarButtons()
        for view in segmentBarView.subviews {
            if view.isKindOfClass(UIButton) {
                c.append(view as! UIButton)
            }
        }
        self.view.addSubview(segmentBarView)
        setupSelectionBar()
    }
    
    func textWidth(text:String) -> CGFloat {
        let font = UIFont(name: "HelveticaNeue-Medium", size: 15.0)
        let size = text.sizeWithAttributes([NSFontAttributeName: font!])
        return size.width
    }

    private func setupSegmentBarButtons() {
        if let buttonList = titleBarDataSource {
            
                for i in 0 ..< buttonList.count {
                    if flagCenter == false {
                    buttonWidthArray.append(textWidth(buttonList[i]))
                    } else {
                        buttonWidthArray.append(self.view.bounds.size.width / 2)
                    }
                }
           
            for i in 0 ..< buttonList.count {
                let previousButtonX = i > 0 ? buttonsFrameArray[i-1].origin.x : 0.0
                let previousButtonW = i > 0 ? buttonWidthArray[i-1] : 0.0
                let segmentButton = UIButton(frame: CGRectMake(previousButtonX + previousButtonW + buttonPadding, 0.0, buttonWidthArray[i] + buttonPadding, segementBarHeight))
                buttonsFrameArray.append(segmentButton.frame)
                segmentButton.setTitle(buttonList[i], forState: .Normal)
                segmentButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
                segmentButton.tag = i
                segmentButton.titleLabel!.textAlignment = NSTextAlignment.Center
                segmentButton.addTarget(self, action: #selector(SMSwipeableTabViewController.didSegmentButtonTap(_:)), forControlEvents: .TouchUpInside)
                if let attributes = buttonAttributes {
                    if let bgColor = attributes[SMBackgroundColorAttribute] as? UIColor {
                        segmentButton.backgroundColor = bgColor
                    }
                    
                    if let bgImage = attributes[SMBackgroundImageAttribute] as? UIImage {
                        segmentButton.setBackgroundImage(bgImage, forState: .Normal)
                    }
                    
                    if let normalImages = attributes[SMButtonNormalImagesAttribute] as? [String] {
                        segmentButton.setImage(UIImage(named: normalImages[i]), forState: .Normal)
                    }
                    
                    if let highlightedImages = attributes[SMButtonHighlightedImagesAttribute] as? [String] {
                        segmentButton.setImage(UIImage(named: highlightedImages[i]), forState: .Selected)
                    }
                    
                    if let hideTitle = attributes[SMButtonHideTitleAttribute] as? Bool where hideTitle == true{
                        segmentButton.titleLabel?.hidden = true
                        segmentButton.setTitle("", forState: .Normal)
                    }
                    else{
                        segmentButton.titleLabel?.hidden = false
                    }
                    
                    if let font = attributes[SMFontAttribute] as? UIFont {
                        segmentButton.titleLabel?.font = font
                    }
                    
                    if let foregroundColor = attributes[SMForegroundColorAttribute] as? UIColor {
                        segmentButton.setTitleColor(foregroundColor, forState: .Normal)
                    }
                    
                    if let alpha = attributes[SMAlphaAttribute] as? CGFloat {
                        segmentButton.alpha = alpha
                    }
                }
                
                segmentBarView.addSubview(segmentButton)
                
                if i == buttonList.count-1 {
                    segmentBarView.contentSize = CGSize(width:buttonsFrameArray[i].origin.x + buttonWidthArray[i] + contentSizeOffset, height: segementBarHeight)
                }
            }
        }
    }
    
    private func setupSelectionBar() {
        setupSelectionBarFrame(0)
        selectionBar.backgroundColor = defaultSelectionBarBgColor
        if let attributes = selectionBarAttributes {
            if let bgColor = attributes[SMBackgroundColorAttribute] as? UIColor {
                selectionBar.backgroundColor = bgColor
            }
            else {
                selectionBar.backgroundColor = defaultSelectionBarBgColor
            }
            
            if let bgImage = attributes[SMBackgroundImageAttribute] as? UIImage {
                segmentBarView.backgroundColor = UIColor(patternImage: bgImage)
            }
            
            if let alpha = attributes[SMAlphaAttribute] as? CGFloat {
                selectionBar.alpha = alpha
            }
        }
        segmentBarView.addSubview(selectionBar)
    }
    
    private func setupSelectionBarFrame(index: Int) {
        if buttonsFrameArray.count > 0 {
            let previousButtonX = index > 0 ? buttonsFrameArray[index-1].origin.x : 0.0
            let previousButtonW = index > 0 ? buttonWidthArray[index-1] : 0.0
            if flagCenter == true {
                selectionBar.frame = CGRectMake(previousButtonX + previousButtonW + buttonPadding, segementBarHeight - selectionBarHeight, buttonWidthArray[index], selectionBarHeight)
            } else {
               
            }
//            selectionBar.frame = CGRectMake(previousButtonX + previousButtonW + buttonPadding, segementBarHeight - selectionBarHeight, buttonsFrameArray[index].size.width, selectionBarHeight)
        }
    }
    
    public func viewControllerAtIndex(index: Int) -> UIViewController? {
        if titleBarDataSource?.count == 0 || index >= titleBarDataSource?.count {
            return nil
        }
        let viewController = delegate?.didLoadViewControllerAtIndex(index)
        viewController?.view.tag = index
        return viewController
    }
    
    private func syncScrollView() {
        for view: UIView in (pageViewController?.view.subviews)!
        {
            if view is UIScrollView {
                pageScrollView = view as? UIScrollView
                pageScrollView?.delegate = self
            }
        }
    }
    
    //MARK: Page View Controller Data Source
    public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = viewController.view.tag
        if index == 0 || index == NSNotFound {
            return nil
        }
        
        index -= 1
        c[index].setTitleColor(UIColor.grayColor(), forState: .Normal)
        return viewControllerAtIndex(index)
    }
    
    public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = viewController.view.tag
        if index == NSNotFound {
            return nil
        }
        index += 1
        if index == titleBarDataSource?.count {
            return nil
        }
        return viewControllerAtIndex(index)
    }
    
    public func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            c[currentPageIndex].setTitleColor(UIColor.grayColor(), forState: .Normal)
            if let lastVC = pageViewController.viewControllers?.last {
                currentPageIndex = lastVC.view.tag
            }
            setupSelectionBarFrame(currentPageIndex)
            if flagCenter == true {
                segmentBarView.scrollRectToVisible(CGRectMake(buttonsFrameArray[currentPageIndex].origin.x, 0.0,  buttonWidthArray[currentPageIndex], 20.0), animated: true)
            } else {
                segmentBarView.scrollRectToVisible(CGRectMake(buttonsFrameArray[currentPageIndex].origin.x, 0.0,  buttonWidthArray[currentPageIndex], 20.0), animated: true)
            }
            
            if c.last != nil {
             c.last?.setTitleColor(UIColor.grayColor(), forState: .Normal)
            }
            c[currentPageIndex].setTitleColor(UIColor.redColor(), forState: .Normal)
            app?.cPageIndex = currentPageIndex
        }
    }
    
    func goToViewController(index: Int) {
        
    }
    
    //MARK : Segment Button Action
    func didSegmentButtonTap(sender: UIButton? = nil) {
        let tempIndex = currentPageIndex
        if sender!.tag != tempIndex { c[tempIndex].setTitleColor(UIColor.grayColor(), forState: .Normal) }
        if sender!.tag == 0 {
            //check nil
            if self.app?.viewDict["CurrentOrderVC"] != nil {
                (self.app?.viewDict["CurrentOrderVC"] as! CurrentOrderVC).reloadTable()
            }
        }
        if sender!.tag == 1 {
        }
        if sender!.tag == tempIndex { return }
        let scrollDirection: UIPageViewControllerNavigationDirection = sender!.tag > tempIndex ? .Forward : .Reverse
        pageViewController?.setViewControllers([viewControllerAtIndex(sender!.tag)!], direction: scrollDirection, animated: true, completion: { (complete) -> Void in
            if complete {
                self.currentPageIndex = sender!.tag
                self.app?.cPageIndex = self.currentPageIndex
                if self.flagCenter == true {
                    self.segmentBarView.scrollRectToVisible(CGRectMake(self.buttonsFrameArray[self.currentPageIndex].origin.x, 0.0,  self.buttonWidthArray[self.currentPageIndex], 20.0), animated: true)
                } else {
                    self.segmentBarView.scrollRectToVisible(CGRectMake(self.buttonsFrameArray[self.currentPageIndex].origin.x, 0.0,  self.buttonWidthArray[self.currentPageIndex], self.segementBarHeight), animated: true)
                }
                self.c[sender!.tag].setTitleColor(UIColor.redColor(), forState: .Normal)
            }
        })
    }
    
    func jumpToMyOrderView(){
        let scrollDirection: UIPageViewControllerNavigationDirection =  .Forward
        pageViewController?.setViewControllers([viewControllerAtIndex(0)!], direction: scrollDirection, animated: true, completion: { (complete) -> Void in
            if complete {
                self.c[1].setTitleColor(UIColor.grayColor(), forState: .Normal)
                self.currentPageIndex = 0
                self.c[self.currentPageIndex].setTitleColor(UIColor.redColor(), forState: .Normal)
                self.segmentBarView.scrollRectToVisible(CGRectMake(self.buttonsFrameArray[self.currentPageIndex].origin.x, 0.0,  self.buttonWidthArray[self.currentPageIndex], self.segementBarHeight), animated: true)
            }
        })        
    }
    
    func jumpToCurrentOrderView(){
        let scrollDirection: UIPageViewControllerNavigationDirection =  .Reverse
        pageViewController?.setViewControllers([viewControllerAtIndex(1)!], direction: scrollDirection, animated: true, completion: { (complete) -> Void in
            if complete {
                self.c[0].setTitleColor(UIColor.grayColor(), forState: .Normal)
                self.currentPageIndex = 1
                self.c[self.currentPageIndex].setTitleColor(UIColor.redColor(), forState: .Normal)
                self.segmentBarView.scrollRectToVisible(CGRectMake(self.buttonsFrameArray[self.currentPageIndex].origin.x, 0.0,  self.buttonWidthArray[self.currentPageIndex], self.segementBarHeight), animated: true)
            }
        })
    }

    //MARK : ScrollView Delegate Methods
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        let xFromCenter:CGFloat = self.view.frame.size.width-scrollView.contentOffset.x
        let xCoor = buttonsFrameArray[currentPageIndex].origin.x;
        selectionBar.frame = CGRectMake(xCoor-xFromCenter/kSelectionBarSwipeConstant, selectionBar.frame.origin.y, buttonWidthArray[currentPageIndex], selectionBar.frame.size.height)
        let center: CGFloat = self.view.bounds.size.width / 2
        let distance :CGFloat = xCoor - center + buttonWidthArray[currentPageIndex] / 2 + buttonPadding / 2
        if self.flagCenter == false {
            if currentPageIndex == 0 && flagFirstLoad == true{
                flagFirstLoad = false
                segmentBarView.setContentOffset(CGPointMake(distance, buttonsFrameArray[currentPageIndex].origin.y), animated: false)
            } else {
                segmentBarView.setContentOffset(CGPointMake(distance, buttonsFrameArray[currentPageIndex].origin.y), animated: true)
            }
        }
    }
}

