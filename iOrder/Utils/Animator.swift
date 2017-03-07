//
//  Animator.swift
//  iOrder
//
//  Created by mhtran on 7/14/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit

class Animator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration    = 0.3
    var presenting  = true
    var originFrame = CGRect.zero
    
    var dismissCompletion: (()->())?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView()!
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        
        let photoView = presenting ? toView : transitionContext.viewForKey(UITransitionContextFromViewKey)!
        
        let initialFrame = presenting ? originFrame : photoView.frame
        let finalFrame = presenting ? photoView.frame : originFrame
        
        //if true frame will grow from initial to final frame on x-axis
        
        let xScaleFactor = presenting ? 0 : finalFrame.width / initialFrame.width
        
        //if true frame will grow from initial to final frame on y-axis
        
        let yScaleFactor = presenting ? 0 : finalFrame.height / initialFrame.height
        
        //scale transform
        let scaleTransform = CGAffineTransformMakeScale(xScaleFactor, yScaleFactor)
        
        if presenting {
            photoView.transform = scaleTransform
            photoView.center = CGPoint(
                x: containerView.center.x,
                y: containerView.center.y)
            photoView.clipsToBounds = true
        }
        
        //add subview
        containerView.addSubview(toView)
        
        //bring subview to front
        containerView.bringSubviewToFront(photoView)
        
        
        UIView.animateWithDuration(duration, delay:0.0,
                                   options: [.CurveEaseOut],
                                   animations: {
                                    
                                    photoView.transform = self.presenting ? CGAffineTransformIdentity : scaleTransform
                                    photoView.center = CGPoint(x: containerView.center.x, y: containerView.center.y)
                                    
            }, completion:{_ in
                
                if !self.presenting {
                    self.dismissCompletion?()
                }
                transitionContext.completeTransition(true)
        })
        
        
    }
    
}

