//
//  SpringAnimationViewController.swift
//  Animation
//
//  Created by Milan Kamilya on 15/09/15.
//  Copyright (c) 2015 innofied. All rights reserved.
//

import UIKit

class SpringAnimationViewController: UIViewController {
    
    //MARK:- CONTANTS
    let themeColor: UIColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
    
    //MARK:- STORYBOARD COMPONENT
    @IBOutlet weak var textViewForMessagingText: UITextView!
    @IBOutlet weak var viewAtBackOfMessagingText: UIView!
    @IBOutlet weak var slideTimeDuration: UISlider!
    @IBOutlet weak var slideDelay: UISlider!
    @IBOutlet weak var slideDamping: UISlider!
    @IBOutlet weak var slideVelocity: UISlider!
    
    //MARK:- PRIVATE PROPERTIES
    var springView: MKFluidView?
    
    //MARK: - LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        springView = MKFluidView(frame: CGRectMake(0, 0, 320, self.view.frame.size.height - viewAtBackOfMessagingText.frame.size.height))
        springView?.backgroundColor = UIColor.orangeColor()
        springView?.fillColor = themeColor
        springView?.directionOfBouncing = .SurfaceTension
        springView?.animationDuration = NSTimeInterval(slideTimeDuration.value)
        springView?.animationSpecs = Animation( sideDelay : 0.1, sideDumping : 0.4, sideVelocity : 0.9, centerDelay: NSTimeInterval( slideDelay.value), centerDumping: CGFloat(slideDamping.value), centerVelocity: CGFloat(slideVelocity.value) )
    
        self.view.addSubview(springView!)
        
        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
                
    }
    
    //MARK:- USER INTERACTION
    @IBAction func springAnimationFetched(sender: UIButton) {
        
        //println("\(slideTimeDuration.value)  \(slideDelay.value)  \(slideDamping.value)  \(slideVelocity.value)")
        
        var menuView = UIView(frame: CGRectMake(0, 100, 320, 60))
        menuView.backgroundColor = themeColor
        
        // 🚀 Following line goes with UILabel
        //springView = MKFluidView(frame: CGRectMake(150-12, viewAtBackOfMessagingText.frame.origin.y - 20, 150+24, 20))
        springView = MKFluidView(frame: CGRectMake(0, viewAtBackOfMessagingText.frame.origin.y - 50, 320, 50))

        
        self.view.addSubview(springView!)
        springView?.curveType = .EggShape
        springView?.fillColor = themeColor
        springView?.directionOfBouncing = .SurfaceTension
        springView?.animationDuration = NSTimeInterval(slideTimeDuration.value)
        springView?.animationSpecs = Animation( sideDelay : 0.1, sideDumping : 0.4, sideVelocity : 0.9, centerDelay: NSTimeInterval( slideDelay.value), centerDumping: CGFloat(slideDamping.value), centerVelocity: CGFloat(slideVelocity.value) )
        
        springView?.animateWithSurfaceTension(callback: { () -> Void in
            self.springView?.removeFromSuperview()
            self.springView = nil
        })
        
        // UILabel Animation
        
        // TODO:- Open Label Animation
        
        /*
        var labelMessage: UILabel = UILabel(frame: CGRectMake(100, viewAtBackOfMessagingText.frame.origin.y , 120, 50))
        labelMessage.text = "Hello World"
        labelMessage.textAlignment = .Center
        labelMessage.backgroundColor = themeColor
        labelMessage.layer.cornerRadius = 25.0
        labelMessage.layer.masksToBounds = true
        self.view.addSubview(labelMessage)
        
        
        UIView.animateWithDuration( NSTimeInterval(slideTimeDuration.value + 0.45), delay: NSTimeInterval(slideDelay.value), usingSpringWithDamping: CGFloat(slideDamping.value), initialSpringVelocity: CGFloat(slideVelocity.value), options: (UIViewAnimationOptions.BeginFromCurrentState | UIViewAnimationOptions.AllowUserInteraction), animations: { () -> Void in
            
            labelMessage.frame = CGRectMake(100, self.viewAtBackOfMessagingText.frame.origin.y - 60, 120, 50)
            
        }, completion:{ (finish) -> Void in
            
            UIView.animateWithDuration(NSTimeInterval(0.5), delay: NSTimeInterval(0.0), usingSpringWithDamping: CGFloat(0.6), initialSpringVelocity: CGFloat(0.5), options: (UIViewAnimationOptions.BeginFromCurrentState), animations: { () -> Void in
                
                labelMessage.frame = CGRectMake(180, self.viewAtBackOfMessagingText.frame.origin.y - 200, 120, 50)

            }, completion: { (finish) -> Void in
                labelMessage.removeFromSuperview()
            })
        })
        */
        
    }
    
    //MARK:- CUSTOM VIEW
    
    //MARK:- UTILITY METHODS
    func textDrawing() {
        
        let path: UIBezierPath = UIBezierPath()
        path.moveToPoint(CGPointMake(20, 300))
        path.addCurveToPoint(CGPointMake(300, 300), controlPoint1: CGPointMake(230, 230), controlPoint2: CGPointMake(160, 370))
        path.stroke()
        
        var shapeLayer: CAShapeLayer = CAShapeLayer()
        shapeLayer.path = path.CGPath
        
        
        self.view.layer.addSublayer(shapeLayer)
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if touches.count == 1 {
            for touch in touches {
                
                let touchLocal: UITouch = touch as! UITouch
                var point: CGPoint = touchLocal.locationInView(touchLocal.view)
                if CGRectContainsPoint(viewAtBackOfMessagingText.bounds, point)  {
                    point = touchLocal.view.convertPoint(point, toView: nil)
                    springView?.initializeTouchRecognizer(point)
                }
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
