//
//  LineAnimationViewController.swift
//  Animation
//
//  Created by Milan Kamilya on 14/09/15.
//  Copyright (c) 2015 innofied. All rights reserved.
//

import UIKit

class LineAnimationViewController: UIViewController {
    
    //MARK:- CONTANTS
    let shapeRect = CAShapeLayer()
    let waitingRect = CAShapeLayer()
    
    //MARK:- STORYBOARD COMPONENT
    
    //MARK:- PUBLIC PROPERTIES
    var toggle: Bool? = false
    
    //MARK:- PRIVATE PROPERTIES
    
    //MARK: - LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //self.drawLine()
        
        self.loadSpinningAnimation()
    }
    
    //MARK:- CUSTOM VIEW
    
    func drawLine() {
        
        let line = UIBezierPath()
        line.moveToPoint(CGPointMake(0,100))
        line.addLineToPoint(CGPointMake(250, 100))
        line.addArcWithCenter(CGPointMake(250, 75), radius: CGFloat(25.0), startAngle: CGFloat(1.0*M_PI_2), endAngle: CGFloat(-3.0*M_PI_2), clockwise: false)
        
        

        
        shapeRect.path = line.CGPath
        shapeRect.strokeColor = UIColor.grayColor().CGColor
        shapeRect.fillColor = UIColor.clearColor().CGColor
        shapeRect.strokeStart = 0.0
        shapeRect.strokeEnd = 0.6
        self.view.layer.addSublayer(shapeRect)
        
        
    }
    
    @IBAction func toggleButtonClicked(sender: UIButton) {
        
        if toggle! {
            
            CATransaction.begin()
            
            let start = CABasicAnimation(keyPath: "strokeStart")
            start.toValue = 0.0
            let end = CABasicAnimation(keyPath: "strokeEnd")
            end.toValue = 0.61
            
            // 4
            let group = CAAnimationGroup()
            group.animations = [start, end]
            group.duration = 2.5
            group.repeatCount = 1
            group.delegate = self
            self.shapeRect.addAnimation(group, forKey: "k")

            CATransaction.setCompletionBlock({ () -> Void in
                
                
                self.shapeRect.strokeStart = 0.0
                self.shapeRect.strokeEnd = 0.61
                self.toggle = false
                
                println("Ehlloe")
            })
        
            CATransaction.commit()

        } else {
            
            CATransaction.begin()
            
            let start = CABasicAnimation(keyPath: "strokeStart")
            start.toValue = 0.61
            let end = CABasicAnimation(keyPath: "strokeEnd")
            end.toValue = 1
            
            // 4
            let group = CAAnimationGroup()
            group.animations = [start, end]
            group.duration = 2.5
            group.repeatCount = 1
            self.shapeRect.addAnimation(group, forKey: "k")


            CATransaction.setCompletionBlock({ () -> Void in
                self.shapeRect.strokeStart = 0.61
                self.shapeRect.strokeEnd = 1.0
                self.toggle = true
            })
            
            CATransaction.commit()
            
        }
        
    }
    
    
    func loadSpinningAnimation() {
        
        // Draw Path
        let line = UIBezierPath()
        line.moveToPoint(CGPointMake(150,200))
        line.addLineToPoint(CGPointMake(200, 200))
        line.addLineToPoint(CGPointMake(150, 100))
        line.addLineToPoint(CGPointMake(200, 100))
        line.closePath()
        
        // ShapeLayer
        waitingRect.path = line.CGPath
        waitingRect.strokeColor = UIColor.grayColor().CGColor
        waitingRect.fillColor = UIColor.clearColor().CGColor
        waitingRect.strokeStart = 0.0
        waitingRect.strokeEnd = 0.1
        self.view.layer.addSublayer(waitingRect)
        
        
        // Start animation
        let start = CABasicAnimation(keyPath: "strokeStart")
        start.toValue = 0.9
        let end = CABasicAnimation(keyPath: "strokeEnd")
        end.toValue = 1.0
        
        let group = CAAnimationGroup()
        group.animations = [start, end]
        group.duration = 1.5
        group.repeatCount = HUGE
        group.autoreverses = false
        waitingRect.addAnimation(group, forKey: "Spinning")
        
    }
    
    
    
    //MARK:- UTILITY METHODS
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        print("animationDidStop")
    }
}


