//
//  OHCircleSegue.swift
//  OHCircleSegue
//
//  Created by Øyvind Hauge on 10/01/16.
//  Copyright © 2016 Øyvind Hauge. All rights reserved.
//

import UIKit

class OHCircleSegue: UIStoryboardSegue {
    
    private let duration: CFTimeInterval = 0.2
    private static let stack = Stack()
    
    var circleOrigin: CGPoint
    private var shouldExpand: Bool
    
    override init(identifier: String?, source: UIViewController, destination: UIViewController) {
        
        let centerX = UIScreen.mainScreen().bounds.width*0.5
        let centerY = UIScreen.mainScreen().bounds.height*0.5
        let centerOfScreen = CGPointMake(centerX, centerY)
        
        // Initialize properties
        circleOrigin = centerOfScreen
        shouldExpand = true
        
        super.init(identifier: identifier, source: source, destination: destination)
    }
    
    override func perform() {
        
        if OHCircleSegue.stack.peek() !== destinationViewController {
            OHCircleSegue.stack.push(sourceViewController)
        } else {
            OHCircleSegue.stack.pop()
            shouldExpand = false
        }
        
        let paths = startAndEndPaths(shouldExpand)
        
        let sourceView = sourceViewController.view as UIView!
        let destView = destinationViewController.view as UIView!
        
        // Add destination controllers view to the main application window
        let window = UIApplication.sharedApplication().keyWindow
        if shouldExpand {
            window?.insertSubview(destView, aboveSubview: sourceView)
        } else {
            window?.insertSubview(destView, atIndex:0)
        }
        
        // Create circle mask and apply it to the view of the destination controller
        let mask = CAShapeLayer()
        mask.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        mask.position = circleOrigin
        mask.path = paths.start
        (shouldExpand ? destView : sourceView).layer.mask = mask
        
        // Call method for creating animation and add it to the view's mask
        (shouldExpand ? destView : sourceView).layer.mask?.addAnimation(scalingAnimation(paths.end), forKey: nil)
    }
    
    // MARK: Animation delegate
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if shouldExpand {
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
        animation.duration = duration
        animation.fillMode = kCAFillModeBoth
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.delegate = self
        return animation
    }
    
    private func startAndEndPaths(shouldExpand: Bool) -> (start: CGPathRef, end: CGPathRef) {
        
        // The hypothenuse is the diaonal of the screen
        // The diagonal of the screen is the diameter we
        // need the big circle to be to cover the whole screen
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height
        let rw = width + fabs(width/2 - circleOrigin.x)
        let rh = height + fabs(height/2 - circleOrigin.y)
        let h1 = hypot(width/2 - circleOrigin.x, height/2 - circleOrigin.y)
        let hyp = CGFloat(sqrtf(powf(Float(rw), 2) + powf(Float(rh), 2)))
        let dia = h1 + hyp
        
        // TODO: Clean up implementation ^
        
        print("h1: \(h1) hyp: \(hyp) rw: \(rw) rh: \(rh) width: \(width) height: \(height)")
        
        // The two circle sizes we will animate to/from
        let path1 = UIBezierPath(ovalInRect: CGRectZero).CGPath
        let path2 = UIBezierPath(ovalInRect: CGRectMake(-dia/2, -dia/2, dia, dia)).CGPath
        
        return shouldExpand ? (path1, path2) : (path2, path1)
    }
    
    // MARK: Simple stack implementation for keeping track of view controllers
    
    private class Stack {
        
        private var N = 0
        private var stackArray = Array<UIViewController>()
        
        func push(vc: UIViewController) {
            stackArray.append(vc)
            N++
        }
        
        func pop() -> UIViewController? {
            if stackArray.last != nil {
                let vc = stackArray.last
                stackArray.removeLast()
                N--
                return vc!
            } else {
                return nil
            }
        }
        
        func peek() -> UIViewController? {
            if stackArray.last != nil {
                return stackArray.last
            }
            return nil
        }
        
        func size() -> Int {
            return N
        }
    }
}