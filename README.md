# OHCircleSegue
Custom UIStoryBoardSegue with circular transition/animation

![Demo](/Resources/segue_demo.gif)

## Installation

### Manual
Drag the OHCircleSegue.swift class into you project and you're done.

### CocoaPods

Unlikely

## Usage

- 1. In your storyboard, create a segue between two view controllers
- 2. Go to the attributes inspector for the newly created segue and set it up like shown below (note that 'Kind' can be set to anything)

![Usage 1](/Resources/usage_1.png)

- 3. Repeat step 1 and 2 for the unwind segue

In this example, the performSegueWithIdentifier method is called from touchesBegan. To determine where on the screen animation should originate from, override the prepareForSegue function:

    ```swift
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // sender object is an instance of UITouch in this case 
        let touch = sender as! UITouch
        
        // Access the circleOrigin property and assign preferred CGPoint
        (segue as! OHCircleSegue).circleOrigin = touch.locationInView(view)
    }
    ```

### UIButton example

Starting the transition from a UIButton (note that this will aslo work for other UIKit components as long as user interactions are enabled).

1. Add a button the view controller you want to transition from and hook it up with an IBAction like shown below

    ```swift
    @IBAction func buttonTapped(sender: AnyObject) {
        
        // We can force unwrap here since we are certain sender is a UIButton
        let button = sender as! UIButton
        
        // Call method to perform our OHCircleSegue, using our button as the sender
        performSegueWithIdentifier("Segue", sender: button)
    }
    ```
    
2. In the prepareForSegue method, unwrap the button and use it to determine the origin of our transition
    
    ```swift
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // No problem to force unwrap in this case
        let button = sender as! UIButton
        
        // Set the circleOrigin property of the segue to the center of the button
        (segue as! OHCircleSegue).circleOrigin = button.center
    }
    ```

## License

OHCircleSegue is available under the MIT license. See the LICENSE.md file for more info.
