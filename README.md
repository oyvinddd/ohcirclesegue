# OHCircleSegue
Custom UIStoryBoardSegue with circular transition/animation

![Demo](/Resources/segue_demo.gif)

## Installation

### Manual
Drag the OHCircleSegue.swift class into you project and you're done.

### CocoaPods

Coming soon

## Usage

- 1. In your storyboard, create a segue between two view controllers
- 2. Go to the attributes inspector for the newly created segue and set it up like shown below (note that 'Kind' can be set to anything)

![Usage 1](/Resources/usage_1.png)

- 3. Repeat step 1 and 2 for the unwind segue

To determine where on the screen animation should originat from, override the prepareForSegue function:

```
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let touch = sender as! UITouch
        (segue as! OHCircleSegue).circleOrigin = touch.locationInView(view)
    }
```

## License

OHCircleSegue is available under the MIT license. See the LICENSE.md file for more info.
