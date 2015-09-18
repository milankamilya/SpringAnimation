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

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
                
    }
    
    //MARK:- USER INTERACTION
    @IBAction func springAnimationFetched(sender: UIButton) {
        
        
        println("\(slideTimeDuration.value)  \(slideDelay.value)  \(slideDamping.value)  \(slideVelocity.value)")
        
        var menuView = UIView(frame: CGRectMake(0, 100, 320, 60))
        menuView.backgroundColor = themeColor
        
        // 🚀 Following line goes with UILabel
        //springView = MKFluidView(frame: CGRectMake(150-12, viewAtBackOfMessagingText.frame.origin.y - 20, 150+24, 20))
        springView = MKFluidView(frame: CGRectMake(0, viewAtBackOfMessagingText.frame.origin.y - 200, 320, 200))

        
        self.view.addSubview(springView!)
        springView?.curveType = .EggShape
        springView?.fillColor = themeColor
        springView?.directionOfBouncing = .SurfaceTension
        springView?.animationDuration = NSTimeInterval(slideTimeDuration.value)
        springView?.animationSpecs = Animation( sideDelay : 0.1, sideDumping : 0.4, sideVelocity : 0.9, centerDelay: NSTimeInterval( slideDelay.value), centerDumping: CGFloat(slideDamping.value), centerVelocity: CGFloat(slideVelocity.value) )
        
        springView?.animate(true, callback: { () -> Void in
            self.springView?.removeFromSuperview()
            self.springView = nil
        })
        
        // UILabel Animation
        
        // TODO:- Open Label Animation
        /*
        var labelMessage: UILabel = UILabel(frame: CGRectMake(150, viewAtBackOfMessagingText.frame.origin.y, 150, 50))
        labelMessage.text = "Hello World"
        labelMessage.textAlignment = .Center
        labelMessage.backgroundColor = themeColor
        labelMessage.layer.cornerRadius = 25.0
        labelMessage.layer.masksToBounds = true
        self.view.addSubview(labelMessage)
        
        
        UIView.animateWithDuration( NSTimeInterval(slideTimeDuration.value), delay: NSTimeInterval(slideDelay.value), usingSpringWithDamping: CGFloat(slideDamping.value), initialSpringVelocity: CGFloat(slideVelocity.value), options: (UIViewAnimationOptions.BeginFromCurrentState | UIViewAnimationOptions.AllowUserInteraction), animations: { () -> Void in
            
            labelMessage.frame = CGRectMake(150, self.viewAtBackOfMessagingText.frame.origin.y - 70, 150, 50)
            
        }, completion:{ (finish) -> Void in
            labelMessage.removeFromSuperview()
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


}
