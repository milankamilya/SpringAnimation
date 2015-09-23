//
//  FluidVC.swift
//  Animation
//
//  Created by Milan Kamilya on 21/09/15.
//  Copyright (c) 2015 innofied. All rights reserved.
//

import UIKit

class FluidVC: UIViewController {

    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    //MARK:- CONTANTS
    let themeColor: UIColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
    
    //MARK:- PRIVATE PROPERTIES
    var springView: MKFluidView?
    
    //MARK: - LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        springView = MKFluidView(frame: CGRectMake(0, 0, 320, self.view.frame.size.height ))
        //springView?.backgroundColor = UIColor.orangeColor()
        springView?.fillColor = themeColor
        springView?.directionOfBouncing = .SurfaceTensionTopInward
        
        self.view.addSubview(springView!)
        
        
    }


    @IBAction func segmentedControlViewChanged(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
            case 0 :
                springView?.directionOfBouncing = .SurfaceTensionTopInward
            case 1 :
                springView?.directionOfBouncing = .SurfaceTensionLeftInward
            case 2 :
                springView?.directionOfBouncing = .SurfaceTensionBottomInward
            case 3 :
                springView?.directionOfBouncing = .SurfaceTensionRightInward
            default :
                print("Check segmented Control Value")
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if touches.count == 1 {
            for touch in touches {
                
                let touchLocal: UITouch = touch as! UITouch
                var point: CGPoint = touchLocal.locationInView(touchLocal.view)
                springView?.initializeTouchRecognizer(point)
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if touches.count == 1 {
            for touch in touches {
                let touchLocal: UITouch = touch as! UITouch
                
                var point: CGPoint = touchLocal.locationInView(touchLocal.view)
                point = touchLocal.view.convertPoint(point, toView: nil)
                
                springView?.movingTouchRecognizer(point)
                
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if touches.count == 1 {
            for touch in touches {
                let touchLocal: UITouch = touch as! UITouch
                
                var point: CGPoint = touchLocal.locationInView(touchLocal.view)
                point = touchLocal.view.convertPoint(point, toView: nil)
                
                springView?.endTouchRecognizer(point)
                
            }
        }
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        if touches.count == 1 {
            for touch in touches {
                let touchLocal: UITouch = touch as! UITouch
                
                var point: CGPoint = touchLocal.locationInView(touchLocal.view)
                point = touchLocal.view.convertPoint(point, toView: nil)
                springView?.endTouchRecognizer(point)
                
            }
        }
    }
    

}
