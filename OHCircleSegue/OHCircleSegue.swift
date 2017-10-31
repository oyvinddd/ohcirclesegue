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
        let centerX = UIScreen.main.bounds.width*0.5
        let centerY = UIScreen.main.bounds.height*0.5
        let centerOfScreen = CGPoint(x:centerX, y:centerY)
        
        // Initialize properties
        circleOrigin = centerOfScreen
        shouldUnwind = false
        
        super.init(identifier: identifier, source: source, destination: destination)
    }
    
    override func perform() {
        
        if OHCircleSegue.isAnimating {
            return
        }
        
        if OHCircleSegue.stack.peek() !== destination {
            OHCircleSegue.stack.push(vc: source)
        } else {
            OHCircleSegue.stack.pop()
            shouldUnwind = true
        }
        
        let sourceView = source.view as UIView!
        let destView = destination.view as UIView!
        
        // Add source (or destination) controller's view to the main application
        // window depending of if this is a normal or unwind segue
        let window = UIApplication.shared.keyWindow
        if !shouldUnwind {
            window?.insertSubview(destView!, aboveSubview: sourceView!)
        } else {
            window?.insertSubview(destView!, at:0)
        }
        
        let paths = startAndEndPaths(shouldUnwind: !shouldUnwind)
        
        // Create circle mask and apply it to the view of the destination controller
        let mask = CAShapeLayer()
        mask.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        mask.position = circleOrigin
        mask.path = paths.start
        (shouldUnwind ? sourceView : destView)?.layer.mask = mask
        
        // Call method for creating animation and add it to the view's mask
        (shouldUnwind ? sourceView : destView)?.layer.mask?.add(scalingAnimation(destinationPath: paths.end), forKey: nil)
    }
    
    // MARK: Animation delegate
    
    func animationDidStart(_ anim: CAAnimation) {
        OHCircleSegue.isAnimating = true
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool)  {
        OHCircleSegue.isAnimating = false
        if !shouldUnwind {
            source.present(destination, animated: false, completion: nil)
        } else {
            source.dismiss(animated: false, completion: nil)
        }
    }
    
    // MARK: Helper methods
    
    private func scalingAnimation(destinationPath: CGPath) -> CABasicAnimation {
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.toValue = destinationPath
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeBoth
        animation.duration = shouldUnwind ? OHCircleSegue.contractDur : OHCircleSegue.expandDur
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.delegate = self
        return animation
    }
    
    private func startAndEndPaths(shouldUnwind: Bool) -> (start: CGPath, end: CGPath) {
        
        // The hypothenuse is the diagonal of the screen. Further, we use this diagonal as 
        // the diameter of the big circle. This way we are always certain that the big circle 
        // will cover the whole screen.
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        let rw = width + fabs(width/2 - circleOrigin.x)
        let rh = height + fabs(height/2 - circleOrigin.y)
        let h1 = hypot(width/2 - circleOrigin.x, height/2 - circleOrigin.y)
        let hyp = CGFloat(sqrtf(powf(Float(rw), 2) + powf(Float(rh), 2)))
        let dia = h1 + hyp
        
        // The two circle sizes we will animate to/from
        let path1 = UIBezierPath(ovalIn: CGRect.zero).cgPath
        let path2 = UIBezierPath(ovalIn: CGRect(x:-dia/2, y:-dia/2, width:dia, height:dia)).cgPath
        
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
