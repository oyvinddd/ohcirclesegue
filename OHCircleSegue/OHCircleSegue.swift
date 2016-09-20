//
//  OHCircleSegue.swift
//  OHCircleSegue
//
//  Created by Øyvind Hauge on 10/01/16.
//  Copyright © 2016 Øyvind Hauge. All rights reserved.
//

import UIKit

class OHCircleSegue: UIStoryboardSegue, CAAnimationDelegate {
    
    private static let expandDur: CFTimeInterval = 0.35 // Change to make transition faster/slower
    private static let contractDur: CFTimeInterval = 0.15 // Change to make transition faster/slower
    private static let stack = Stack()
    private static var isAnimating = false
    
    var circleOrigin: CGPoint
    private var shouldUnwind: Bool
    
    override init(identifier: String?, source: UIViewController, destination: UIViewController) {
        
        // By default, transition starts from the center of the screen,
        // so let's find the center when segue is first initialized
        let centerX = UIScreen.mainScreen().bounds.width*0.5
        let centerY = UIScreen.mainScreen().bounds.height*0.5
        let centerOfScreen = CGPointMake(centerX, centerY)
        
        // Initialize properties
        circleOrigin = centerOfScreen
        shouldUnwind = false
        
        super.init(identifier: identifier, source: source, destination: destination)
    }
    
    override func perform() {
        
        if OHCircleSegue.isAnimating {
            return
        }
        
        if OHCircleSegue.stack.peek() !== destinationViewController {
            OHCircleSegue.stack.push(sourceViewController)
        } else {
            OHCircleSegue.stack.pop()
            shouldUnwind = true
        }
        
        let sourceView = sourceViewController.view as UIView!
        let destView = destinationViewController.view as UIView!
        
        // Add source (or destination) controller's view to the main application
        // window depending of if this is a normal or unwind segue
        let window = UIApplication.sharedApplication().keyWindow
        if !shouldUnwind {
            window?.insertSubview(destView, aboveSubview: sourceView)
        } else {
            window?.insertSubview(destView, atIndex:0)
        }
        
        let paths = startAndEndPaths(!shouldUnwind)
        
        // Create circle mask and apply it to the view of the destination controller
        let mask = CAShapeLayer()
        mask.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        mask.position = circleOrigin
        mask.path = paths.start
        (shouldUnwind ? sourceView : destView).layer.mask = mask
        
        // Call method for creating animation and add it to the view's mask
        (shouldUnwind ? sourceView : destView).layer.mask?.addAnimation(scalingAnimation(paths.end), forKey: nil)
    }
    
    // MARK: Animation delegate
    
    func animationDidStart(anim: CAAnimation) {
        OHCircleSegue.isAnimating = true
    }
    
    func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        OHCircleSegue.isAnimating = false
        if !shouldUnwind {
            sourceViewController.presentViewController(destinationViewController, animated: false, completion: nil)
        } else {
            sourceViewController.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    // MARK: Helper methods
    
    private func scalingAnimation(destinationPath: CGPathRef) -> CABasicAnimation {
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.toValue = destinationPath
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeBoth
        animation.duration = shouldUnwind ? OHCircleSegue.contractDur : OHCircleSegue.expandDur
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.delegate = self
        return animation
    }
    
    private func startAndEndPaths(shouldUnwind: Bool) -> (start: CGPathRef, end: CGPathRef) {
        
        // The hypothenuse is the diagonal of the screen.
        // Further, we use this diagonal as the diameter of the big circle.
        // This way we are always certain that the big circle will cover the whole screen.
        // TODO: Clean up below implementation
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height
        let rw = width + fabs(width/2 - circleOrigin.x)
        let rh = height + fabs(height/2 - circleOrigin.y)
        let h1 = hypot(width/2 - circleOrigin.x, height/2 - circleOrigin.y)
        let hyp = CGFloat(sqrtf(powf(Float(rw), 2) + powf(Float(rh), 2)))
        let dia = h1 + hyp
        
        //print("h1: \(h1) hyp: \(hyp) rw: \(rw) rh: \(rh) width: \(width) height: \(height)")
        
        // The two circle sizes we will animate to/from
        let path1 = UIBezierPath(ovalInRect: CGRectZero).CGPath
        let path2 = UIBezierPath(ovalInRect: CGRectMake(-dia/2, -dia/2, dia, dia)).CGPath
        
        // If shouldUnwind flag is true, we should go from big to small circle, or else go from small to big
        return shouldUnwind ? (path1, path2) : (path2, path1)
    }
    
    // MARK: Stack implementation
    
    // Simple stack implementation for keeping track of our view controllers
    private class Stack {
        
        private var stackArray = Array<UIViewController>()
        private var size: Int {
            get {
                return stackArray.count
            }
        }
        
        func push(vc: UIViewController) {
            stackArray.append(vc)
        }
        
        func pop() -> UIViewController? {
            if let last = stackArray.last {
                stackArray.removeLast()
                return last
            }
            return nil
        }
        
        func peek() -> UIViewController? {
            return stackArray.last
        }
    }
}
