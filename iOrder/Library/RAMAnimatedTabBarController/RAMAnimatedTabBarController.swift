//  AnimationTabBarController.swift
//
// Copyright (c) 11/10/14 Ramotion Inc. (http://ramotion.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import CoreData


extension RAMAnimatedTabBarItem {

    override public var badgeValue: String? {
        get {
            return badge?.text
        }
        set(newValue) {
            
            if newValue == nil {
                badge?.removeFromSuperview()
                badge = nil;
                return
            }
            
            if let iconView = iconView, let contanerView = iconView.icon.superview where badge == nil {
                badge = RAMBadge.badge()
                badge!.addBadgeOnView(contanerView)
            }
            
            badge?.text = newValue
        }
    }
}

public class RAMAnimatedTabBarItem: UITabBarItem {
    
    var app = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet public var animation: RAMItemAnimation!
    
    public var textFont: UIFont = UIFont.systemFontOfSize(14)
    @IBInspectable public var textColor: UIColor = UIColor.blackColor()
    @IBInspectable public var iconColor: UIColor = UIColor.clearColor() // if alpha color is 0 color ignoring
    
    @IBInspectable var bgDefaultColor: UIColor = UIColor.clearColor() // background color
    @IBInspectable var bgSelectedColor: UIColor = UIColor.clearColor()
    
    public var badge: RAMBadge? // use badgeValue to show badge
    
    public var iconView: (icon: UIImageView, textLabel: UILabel)?
    
    public func playAnimation() {
        
        assert(animation != nil, "add animation in UITabBarItem")
        guard animation != nil && iconView != nil else  {
            return
        }
        animation.playAnimation(iconView!.icon, textLabel: iconView!.textLabel)
    }
    
    public func deselectAnimation() {
        
        guard animation != nil && iconView != nil else  {
            return
        }
        
        animation.deselectAnimation(
            iconView!.icon,
            textLabel: iconView!.textLabel,
            defaultTextColor: textColor,
            defaultIconColor: iconColor)
    }
    
    public func selectedState() {
        guard animation != nil && iconView != nil else  {
            return
        }
        
        animation.selectedState(iconView!.icon, textLabel: iconView!.textLabel)
    }
}

extension  RAMAnimatedTabBarController {
    
    public func changeSelectedColor(textSelectedColor:UIColor, iconSelectedColor:UIColor) {
        
        let items = tabBar.items as! [RAMAnimatedTabBarItem]
        for index in 0 ..< items.count {
            let item = items[index]
            item.animation.textSelectedColor = textSelectedColor
            item.animation.iconSelectedColor = iconSelectedColor
            
            if item == self.tabBar.selectedItem {
                item.selectedState()
            }
        }
    }

    public func animationTabBarHidden(isHidden:Bool) {
        guard let items = tabBar.items as? [RAMAnimatedTabBarItem] else {
            fatalError("items must inherit RAMAnimatedTabBarItem")
        }
        for item in items {
            if let iconView = item.iconView {
                iconView.icon.superview?.hidden = isHidden
            }
        }
        self.tabBar.hidden = isHidden;
    }
    
    public func setSelectIndex(from from:Int,to:Int) {
        self.selectedIndex = to
        guard let items = self.tabBar.items as? [RAMAnimatedTabBarItem] else {
            fatalError("items must inherit RAMAnimatedTabBarItem")
        }
        items[from].deselectAnimation()
        items[to].playAnimation()
    }
}
public class RAMAnimatedTabBarController: UITabBarController{
    public var hideTabbarFlag: Bool = false
    //    public var containers: createViewContainers = createViewContainers()
    var app: AppDelegate! = nil
    
    // MARK: life circle
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        app = UIApplication.sharedApplication().delegate as! AppDelegate
        self.view.backgroundColor = app.genererValue.color
        
        if hideTabbarFlag == false {
            hideTabbarFlag = true
            createTabbarCustom()
        }
        app.viewDict["RAMAnimatedTabBarController"] = self
    }

    func createTabbarCustom() {
        let a = createViewContainers()
        createCustomIcons(a)
    }

    // MARK: create methods
    
    public func createCustomIcons(containers : NSDictionary) {
        
        guard let items = tabBar.items as? [RAMAnimatedTabBarItem] else {
            fatalError("items must inherit RAMAnimatedTabBarItem")
        }
        
        var index = 0
        for item in items {
            
            guard let itemImage = item.image else {
                fatalError("add image icon in UITabBarItem")
            }
            
            guard let container = containers["container\(items.count - 1 - index)"] as? UIView else {
                fatalError()
            }
            container.tag = index
            
            
            let renderMode = CGColorGetAlpha(item.iconColor.CGColor) == 0 ? UIImageRenderingMode.AlwaysOriginal :
                UIImageRenderingMode.AlwaysTemplate
            
            let icon = UIImageView(image: item.image?.imageWithRenderingMode(renderMode))
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.tintColor = item.iconColor
            
            // text
            let textLabel = UILabel()
            textLabel.text = item.title
            textLabel.backgroundColor = UIColor.clearColor()
            textLabel.textColor = item.textColor
            textLabel.font = item.textFont
            textLabel.textAlignment = NSTextAlignment.Center
            textLabel.translatesAutoresizingMaskIntoConstraints = false
            
            container.backgroundColor = app.genererValue.color
            
            container.addSubview(icon)
            createConstraints(icon, container: container, size: itemImage.size, yOffset: 0)
            
            container.addSubview(textLabel)
            let textLabelWidth = tabBar.frame.size.width / CGFloat(items.count) - 5.0
            createConstraints(textLabel, container: container, size: CGSize(width: textLabelWidth , height: 10), yOffset: 16)
            
            item.iconView = (icon:icon, textLabel:textLabel)
            
            if 0 == index { // selected first elemet
                item.selectedState()
                container.backgroundColor = app.genererValue.color
            }
            
            item.image = nil
            item.title = ""
            index += 1
        }
    }
    
    public func createConstraints(view:UIView, container:UIView, size:CGSize, yOffset:CGFloat) {
        
        let constX = NSLayoutConstraint(item: view,
                                        attribute: NSLayoutAttribute.CenterX,
                                        relatedBy: NSLayoutRelation.Equal,
                                        toItem: container,
                                        attribute: NSLayoutAttribute.CenterX,
                                        multiplier: 1,
                                        constant: 0)
        container.addConstraint(constX)
        
        let constY = NSLayoutConstraint(item: view,
                                        attribute: NSLayoutAttribute.CenterY,
                                        relatedBy: NSLayoutRelation.Equal,
                                        toItem: container,
                                        attribute: NSLayoutAttribute.CenterY,
                                        multiplier: 1,
                                        constant: yOffset)
        container.addConstraint(constY)
        
        let constW = NSLayoutConstraint(item: view,
                                        attribute: NSLayoutAttribute.Width,
                                        relatedBy: NSLayoutRelation.Equal,
                                        toItem: nil,
                                        attribute: NSLayoutAttribute.NotAnAttribute,
                                        multiplier: 1,
                                        constant: size.width)
        view.addConstraint(constW)
        
        let constH = NSLayoutConstraint(item: view,
                                        attribute: NSLayoutAttribute.Height,
                                        relatedBy: NSLayoutRelation.Equal,
                                        toItem: nil,
                                        attribute: NSLayoutAttribute.NotAnAttribute,
                                        multiplier: 1,
                                        constant: size.height)
        view.addConstraint(constH)
    }
    
    public func createViewContainers() -> NSDictionary {
        
        guard let items = tabBar.items else {
            fatalError("add items in tabBar")
        }
        
        
        var containersDict = [String: AnyObject]()
        
        for index in 0..<items.count {
            let viewContainer = createViewContainer()
            containersDict["container\(index)"] = viewContainer
        }
        
        var formatString = "H:|-(0)-[container0]"
        for index in 1..<items.count {
            formatString += "-(0)-[container\(index)(==container0)]"
        }
        formatString += "-(0)-|"
        let  constranints = NSLayoutConstraint.constraintsWithVisualFormat(formatString,
                                                                           options:NSLayoutFormatOptions.DirectionRightToLeft,
                                                                           metrics: nil,
                                                                           views: (containersDict as [String : AnyObject]))
        view.addConstraints(constranints)
        
        return containersDict
    }
    
    public func createViewContainer() -> UIView {
        let viewContainer = UIView();
        viewContainer.backgroundColor = app.genererValue.color // for test
        viewContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewContainer)
        
        // add gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RAMAnimatedTabBarController.tapHandler(_:)))
        tapGesture.numberOfTouchesRequired = 1
        viewContainer.addGestureRecognizer(tapGesture)
        
        // add constrains
        let constY = NSLayoutConstraint(item: viewContainer,
                                        attribute: NSLayoutAttribute.Bottom,
                                        relatedBy: NSLayoutRelation.Equal,
                                        toItem: view,
                                        attribute: NSLayoutAttribute.Bottom,
                                        multiplier: 1,
                                        constant: 0)
        
        view.addConstraint(constY)
        
        let constH = NSLayoutConstraint(item: viewContainer,
                                        attribute: NSLayoutAttribute.Height,
                                        relatedBy: NSLayoutRelation.Equal,
                                        toItem: nil,
                                        attribute: NSLayoutAttribute.NotAnAttribute,
                                        multiplier: 1,
                                        constant: tabBar.frame.size.height)
        viewContainer.addConstraint(constH)
        
        return viewContainer
    }
    
    // MARK: actions
    
    func runTab(index: Int) {
        selectedIndex = index
        delegate?.tabBarController?(self, didSelectViewController: self)
        
        
    }
    
    /*func showIndicatior() {
        indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        indicator?.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        indicator?.center = self.view.center
        indicator?.layer.cornerRadius = 8
        indicator?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        indicator?.layer.zPosition = 1
        self.view.addSubview(indicator!)
        indicator?.bringSubviewToFront(self.view)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        indicator?.stopAnimating()
        indicator?.startAnimating()
    }*/
    
    func tapHandler(gesture:UIGestureRecognizer) {
        guard let items = tabBar.items as? [RAMAnimatedTabBarItem] else {
            fatalError("items must inherit RAMAnimatedTabBarItem")
        }
        
        guard let gestureView = gesture.view else {
            return
        }
        
        let currentIndex = gestureView.tag
        
        let controller = self.childViewControllers[currentIndex]
        
        if let shouldSelect = delegate?.tabBarController?(self, shouldSelectViewController: controller)
            where !shouldSelect {
            return
        }
        
        if selectedIndex != currentIndex {
            //
//            if currentIndex == 1 && app.flagFirstLoad == false{
//                app.flagFirstLoad = true
//            }
            if Defaults["login"].boolValue == true && Defaults["scan"].boolValue == false {
                print("LOGIN")
                let animationItem : RAMAnimatedTabBarItem = items[currentIndex]
                animationItem.playAnimation()
                if currentIndex == 0 {
                    self.navigationController?.navigationBarHidden = false
                    app.navitabbar.setTitleBar("Home".localized())
                    if self.app?.viewDict["DetailItemVC"] != nil {
                        (self.app?.viewDict["DetailItemVC"] as? DetailItemVC)!.navigationController?.popViewControllerAnimated(false)
                    }                    
                    app.navitabbar.hideSearchBar()
                }
                else if currentIndex == 1 {
                    self.navigationController?.navigationBarHidden = false
                    app.navitabbar.setTitleBar("Home".localized())
                    if self.app?.viewDict["DetailItemVC"] != nil {
                        (self.app?.viewDict["DetailItemVC"] as? DetailItemVC)!.navigationController?.popViewControllerAnimated(false)
                    }
                    app.navitabbar.hideSearchBar()
                }
                    
                else if currentIndex == 2 {
                    self.navigationController?.navigationBarHidden = false
                    app.navitabbar.setTitleBar("My Order".localized())
                    if self.app?.viewDict["DetailItemVC"] != nil {
                        (self.app?.viewDict["DetailItemVC"] as? DetailItemVC)!.navigationController?.popViewControllerAnimated(false)
                    }
                    if self.app?.viewDict["ContainerMyOrderVC"] != nil {
                        (self.app?.viewDict["ContainerMyOrderVC"] as! ContainerMyOrderVC ).swipeableView.jumpToMyOrderView()
                    }
                    if self.app?.viewDict["CurrentOrderVC"] != nil {
                        (self.app?.viewDict["CurrentOrderVC"] as! CurrentOrderVC ).reloadTable()
                    }
                    app.navitabbar.hideSearchBar()
                }
                    
                else if currentIndex == 3 {
                    self.navigationController?.navigationBarHidden = false
                    app.navitabbar.setTitleBar("Bill".localized())
                    if self.app?.viewDict["DetailItemVC"] != nil {
                        (self.app?.viewDict["DetailItemVC"] as? DetailItemVC)!.navigationController?.popViewControllerAnimated(false)
                    }
                    if self.app?.viewDict["ContainerBillVC"] != nil {
                        (self.app?.viewDict["ContainerBillVC"] as! ContainerBillVC ).swipeableView.jumpToMyOrderView()
                    }
                    if self.app?.viewDict["CurrentOrderVC"] != nil {
//                        (self.app?.viewDict["NewBillVC"] as! NewBillVC ).reloadTable()
                    }
                    app.navitabbar.hideSearchBar()
                }
                let deselectItem = items[selectedIndex]
                let containerPrevious : UIView = deselectItem.iconView!.icon.superview!
                containerPrevious.backgroundColor = app.genererValue.color
                deselectItem.deselectAnimation()
                let container : UIView = animationItem.iconView!.icon.superview!
                container.backgroundColor = app.genererValue.color
                selectedIndex = gestureView.tag
                delegate?.tabBarController?(self, didSelectViewController: self)
            }
            if Defaults["login"].boolValue == false && Defaults["scan"].boolValue == false {
                if currentIndex == 0 || currentIndex == 1{
                    let animationItem : RAMAnimatedTabBarItem = items[currentIndex]
                    animationItem.playAnimation()
                    if self.app?.viewDict["DetailItemVC"] != nil {
                        (self.app?.viewDict["DetailItemVC"] as? DetailItemVC)!.navigationController?.popViewControllerAnimated(false)
                    }
                    app.navitabbar.hideSearchBar()
                    
                    if currentIndex == 1 {
                        app.navitabbar.setTitleBar("Menu".localized())
                    } else {
                        app.navitabbar.setTitleBar("Home".localized())
                    }
                    let deselectItem = items[selectedIndex]
                    let containerPrevious : UIView = deselectItem.iconView!.icon.superview!
                    containerPrevious.backgroundColor = app.genererValue.color
                    deselectItem.deselectAnimation()
                    let container : UIView = animationItem.iconView!.icon.superview!
                    container.backgroundColor = app.genererValue.color
                    selectedIndex = gestureView.tag
                    delegate?.tabBarController?(self, didSelectViewController: self)
                } else {
                    if currentIndex == 2 {
                        app.flagJumpToMyOrderVC = true
                    } else if currentIndex == 3{
                        app.flagsBill = true
                    }
                    self.navigationController?.pushViewController({
                        let vc = self.storyboard?.instantiateViewControllerWithIdentifier(SEGUE_LOGGED_IN)
                        return vc!
                        }(), animated: false)
                }
                
            }
            if Defaults["login"].boolValue == true && Defaults["scan"].boolValue == true{
                if currentIndex == 0 || currentIndex == 1 || currentIndex == 2 {
                    self.navigationController?.pushViewController({
                        let vc = self.storyboard?.instantiateViewControllerWithIdentifier(SEGUE_SCANQRCODE) as! ScanQRCodeVC
                        return vc
                        }(), animated: false)                   
                }
            }
            if Defaults["login"].boolValue == false && Defaults["scan"].boolValue == true{                
                    self.navigationController?.pushViewController({
                        let vc = self.storyboard?.instantiateViewControllerWithIdentifier(SEGUE_LOGGED_IN)
                        return vc!
                        }(), animated: false)
            }
        } else if selectedIndex == currentIndex {
            if let navVC = self.viewControllers![selectedIndex] as? UINavigationController {
                navVC.popToRootViewControllerAnimated(false)
            }
        }
    }
    
    //===========================================================
    
    typealias dispatch_cancelable_closure = (cancel : Bool) -> Void
    
    func delay(time:NSTimeInterval, closure:()->Void) ->  dispatch_cancelable_closure? {
        
        func dispatch_later(clsr:()->Void) {
            dispatch_after(
                dispatch_time(
                    DISPATCH_TIME_NOW,
                    Int64(time * Double(NSEC_PER_SEC))
                ),
                dispatch_get_main_queue(), clsr)
        }
        
        var closure:dispatch_block_t? = closure
        var cancelableClosure:dispatch_cancelable_closure?
        
        let delayedClosure:dispatch_cancelable_closure = { cancel in
            if closure != nil {
                if (cancel == false) {
                    dispatch_async(dispatch_get_main_queue(), closure!);
                }
            }
            closure = nil
            cancelableClosure = nil
        }
        
        cancelableClosure = delayedClosure
        
        dispatch_later {
            if let delayedClosure = cancelableClosure {
                delayedClosure(cancel: false)
            }
        }
        
        return cancelableClosure;
    }
    
    func cancel_delay(closure:dispatch_cancelable_closure?) {
        
        if closure != nil {
            closure!(cancel: true)
        }
    }
}
