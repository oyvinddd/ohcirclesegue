//
//  ViewController.swift
//  OHCircleSegue
//
//  Created by Øyvind Hauge on 10/01/16.
//  Copyright © 2016 Øyvind Hauge. All rights reserved.
//

import UIKit

class ViewController3: UIViewController {
    
    @IBOutlet var bckButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bckButton?.layer.cornerRadius = (bckButton?.frame.size.width)!/2
        bckButton?.layer.masksToBounds = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.isKindOfClass(OHCircleSegue) && sender === bckButton {
            (segue as! OHCircleSegue).circleOrigin = (bckButton?.center)!
        }
    }
    
    @IBAction func unwindToController3(segue : UIStoryboardSegue) {
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}