//
//  MKFluidView.swift
//  Animation
//
//  Created by Milan Kamilya on 15/09/15.
//  Copyright (c) 2015 innofied. All rights reserved.
//

import UIKit

struct Animation {
    var sideDelay: NSTimeInterval
    var sideDumping: CGFloat
    var sideVelocity: CGFloat
    var centerDelay: NSTimeInterval
    var centerDumping: CGFloat
    var centerVelocity: CGFloat
}

struct PhysicalObject {
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
    var roundRect: CGFloat
}

enum AnimationType {
    case Normal
    case Wave
}

enum CurveShape {
    case Arc
    case EggShape
    case RoundTrigonal
    case SurfaceTensionPhase0
    case SurfaceTensionPhaseI
    case SurfaceTensionPhaseII
    case SurfaceTensionPhaseIII
}

enum AnimatedObject {
    case SideEdge
    case CenterEdge
    case Both
}

enum DirectionOfBouncing {
    case LeftInward
    case LeftOutward
    case RightInward
    case RightOutward
    case TopInward
    case TopOutward
    case BottomInward
    case BottomOutward
    case SurfaceTension
    case SurfaceTensionLeftInward
    case SurfaceTensionRightInward
    case SurfaceTensionBottomInward
    case SurfaceTensionTopInward
    
}

class MKFluidView: UIView {
    
    //MARK:- CONSTANTS
    let MKAnchorViewDimension: CGFloat = 10.0
    
    //MARK:- PUBLIC PROPERTIES
    var directionOfBouncing: DirectionOfBouncing? = .BottomInward
    var curveType: CurveShape? = .Arc
    var animationSpecs: Animation? = Animation( sideDelay : 0.1, sideDumping : 0.4, sideVelocity : 0.9, centerDelay: 0.0, centerDumping: 0.6, centerVelocity: 0.6 )
    var animatedObject: AnimatedObject? = .Both
    var fillColor: UIColor? = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
    var animationDuration: NSTimeInterval? = 0.5
    
    /// Set this property if you want to have object & Surface tension animation
    var physicalObject: PhysicalObject? = PhysicalObject(x: 100, y: 0, width: 100, height: 50, roundRect: 0)
    
    /// To get wave view with Human Touch
    var humanTouchEnable: Bool? = false
    
    
    //MARK:- PRIVATE PROPERTIES
    private var isShown: Bool? = false
    private var isAnimating: Bool? = false
    private var displayLink: CADisplayLink? = nil
    
    private var menuView: UIView?
    private var centerAnchorView: UIView?
    private var sideAnchorView: UIView?
    private var sideAnchorViewHolder: CGPoint? // It is used for Surface Tension
    
    //MARK:- INITIALIZATION
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.hidden = true
        
        /***************😂 AMAZING FACTS 😈****************
         *
         * If I doesn't set backgroundColor externally,
         * 2nd Animation wasn't working
         **************************************************/
        
        self.backgroundColor = UIColor.clearColor()
        setupAnimationSpecification()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(menuView: UIView) {
        
        // Modify Frame :: I want to build this view to the top of the menuView
        var fakeRect = menuView.frame
        fakeRect.size.height = fakeRect.size.height + 25.0
        
        self.init(frame:fakeRect)
        
        self.menuView = menuView
        fillColor = menuView.backgroundColor
        menuView.backgroundColor = UIColor.redColor()
        self.backgroundColor = UIColor.orangeColor()
        
        
        sideAnchorView = UIView(frame:CGRectMake(CGFloat(-MKAnchorViewDimension/2.0), self.frame.height + CGFloat( -MKAnchorViewDimension/2.0), CGFloat(MKAnchorViewDimension), CGFloat(MKAnchorViewDimension)))
        sideAnchorView?.backgroundColor = UIColor.greenColor()
        centerAnchorView = UIView(frame:CGRectMake(CGFloat(self.frame.size.width/2.0)-MKAnchorViewDimension/2.0, self.frame.size.height + CGFloat(-MKAnchorViewDimension/2.0), CGFloat(MKAnchorViewDimension), CGFloat(MKAnchorViewDimension)))
        centerAnchorView?.backgroundColor = UIColor.greenColor()
        
    }

    //MARK:- DRAWING
    override func drawRect(rect: CGRect) {
        
        if centerAnchorView?.superview == nil {
            //self.addSubview(menuView!)
            self.addSubview(sideAnchorView!)
            self.addSubview(centerAnchorView!)
        }
        
        let path = getPathAccordingToCurveShape(curveType!, direction: directionOfBouncing!)
        
        
        let ctx = UIGraphicsGetCurrentContext()
        CGContextAddPath(ctx, path.CGPath)
        self.fillColor!.setFill()
        CGContextFillPath(ctx)
        
        
        //println("drawRect")
    }
    
    // MARK:- ANIMATE
    func animate(isOpening: Bool, callback onComplition:((Void) -> Void )?) {
        
        if humanTouchEnable! {
            return
        }
        
        self.setupAnimationSpecification()
        
        if isShown! != isOpening && !isAnimating!  {
            if isOpening {
                self.hidden = false
            }
            isAnimating = true
            displayLink = CADisplayLink(target: self, selector: Selector("updateDisplay:"))
            displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            
            UIView.animateWithDuration( self.animationDuration! , delay: animationSpecs!.centerDelay, usingSpringWithDamping: animationSpecs!.centerDumping, initialSpringVelocity: animationSpecs!.centerVelocity, options: (.BeginFromCurrentState | .AllowUserInteraction) , animations: { () -> Void in
                
                self.getFrameForBothViews(isOpening)
                
            }, completion: { (finished) -> Void in
                
                
                UIView.animateWithDuration( self.animationDuration! , delay: self.animationSpecs!.centerDelay, usingSpringWithDamping: self.animationSpecs!.centerDumping, initialSpringVelocity: self.animationSpecs!.centerVelocity, options: (.BeginFromCurrentState | .AllowUserInteraction) , animations: { () -> Void in
                    
                        self.getFrameForBothViews(!isOpening)
                    
                    }, completion: { (finished) -> Void in
                        
                        self.displayLink?.invalidate()
                        self.displayLink = nil
                        self.isShown = isOpening
                        self.isAnimating = false
                        
                        if !isOpening {
                            self.hidden = true
                        }
                        
                        if onComplition != nil {
                            onComplition?()
                        }
                })
            })
        }
        
    }
    
    func animateWithSurfaceTension(callback onComplition:((Void) -> Void )?) {
        
        if humanTouchEnable! {
            return
        }
        
        self.setupAnimationSpecification()
        
        if !isAnimating!  {
            
            self.hidden = false
            
            isAnimating = true
            displayLink = CADisplayLink(target: self, selector: Selector("updateDisplay:"))
            displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            
            curveType = CurveShape.SurfaceTensionPhaseI
            
            UIView.animateWithDuration( self.animationDuration! , delay: animationSpecs!.centerDelay, usingSpringWithDamping: animationSpecs!.centerDumping, initialSpringVelocity: animationSpecs!.centerVelocity, options: (.BeginFromCurrentState | .AllowUserInteraction) , animations: { () -> Void in
                
                self.getFrameForBothViews(true)
                
                }, completion: { (finished) -> Void in
                    
                    self.curveType = CurveShape.SurfaceTensionPhaseII
                    self.sideAnchorViewHolder = self.sideAnchorView?.center
                    
                    
                    UIView.animateWithDuration( NSTimeInterval(0.3) , delay: NSTimeInterval(0.0), options: (UIViewAnimationOptions.CurveEaseOut | UIViewAnimationOptions.AllowUserInteraction), animations: { () -> Void in
                        
                        self.sideAnchorView?.frame = CGRectMake(self.centerAnchorView!.center.x, self.sideAnchorView!.frame.origin.y, self.sideAnchorView!.frame.size.width, self.sideAnchorView!.frame.size.width)
                        
                    }, completion: { (finish) -> Void in
                        
                        self.curveType = CurveShape.SurfaceTensionPhaseIII
                        
                        UIView.animateWithDuration( NSTimeInterval(0.5) , delay: self.animationSpecs!.centerDelay, usingSpringWithDamping: CGFloat(0.3), initialSpringVelocity: self.animationSpecs!.centerVelocity, options: (.BeginFromCurrentState | .AllowUserInteraction) , animations: { () -> Void in
                            
                            self.getFrameForBothViews(false)
                            
                            }, completion: { (finished) -> Void in
                                
                                self.displayLink?.invalidate()
                                self.displayLink = nil
                                //self.isShown = isOpening
                                self.isAnimating = false
                                self.hidden = true
                                
                                if onComplition != nil {
                                    onComplition?()
                                }
                        })
                    })
            })
        }
    }
    
    func initializeTouchRecognizer(ControlPoint: CGPoint) {
        // TASKS ::
        // 1. set View to sideView, centerView
        // 2. set timeInterval 0.1 to move to that location
        // 3. Here Center Point will be set by user Touch point
        // 4. SideViewPoint will be set accordingly
        // 5. DisplayLink setting 
        // 6.
        
        
        if !isAnimating! {
            
            self.hidden = false
            
            isAnimating = true
            displayLink = CADisplayLink(target: self, selector: Selector("updateDisplay:"))
            displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            
            self.curveType = CurveShape.SurfaceTensionPhase0
            self.setFrameToBothAnchorView(ControlPoint)
            self.curveType = CurveShape.SurfaceTensionPhaseI
            
            
            UIView.animateWithDuration(NSTimeInterval(0.1), delay: NSTimeInterval(0.0), options: UIViewAnimationOptions.BeginFromCurrentState  , animations: { () -> Void in
                
                self.setFrameToBothAnchorView(ControlPoint)
                
            }, completion: { (finished) -> Void in
                self.displayLink?.invalidate()
                self.displayLink = nil
                self.hidden = false
                
                self.isAnimating = false
            })
        }
    }
    
    func movingTouchRecognizer(ControlPoint: CGPoint) {
        
        if !isAnimating! {
            
            self.hidden = false
            
            isAnimating = true
            displayLink = CADisplayLink(target: self, selector: Selector("updateDisplay:"))
            displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            
            // 1. set View to sideView, centerView
            var heightOfControlPoint: CGFloat = self.frame.size.height - ControlPoint.y
            var distXBetnPoints: CGFloat = (heightOfControlPoint * 1.5)/2.0
            var xOfSideAnchorView = ControlPoint.x - distXBetnPoints
           
            self.curveType = CurveShape.SurfaceTensionPhaseI
            
            UIView.animateWithDuration(NSTimeInterval(0.1), delay: NSTimeInterval(0.0), options: UIViewAnimationOptions.BeginFromCurrentState  , animations: { () -> Void in
                
                 self.setFrameToBothAnchorView(ControlPoint)
                
                }, completion: { (finished) -> Void in
                    self.displayLink?.invalidate()
                    self.displayLink = nil
                    self.hidden = false
                    
                    self.isAnimating = false
            })
            
            
            
        }
    }
    
    func endTouchRecognizer(ControlPoint: CGPoint) {
        
       // if !isAnimating! {
            
            self.hidden = false
            
            isAnimating = true
            displayLink = CADisplayLink(target: self, selector: Selector("updateDisplay:"))
            displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        
            self.curveType = CurveShape.SurfaceTensionPhaseII
            self.sideAnchorViewHolder = self.sideAnchorView?.center
            
            UIView.animateWithDuration( NSTimeInterval(0.3) , delay: NSTimeInterval(0.0), options: (UIViewAnimationOptions.CurveEaseOut | UIViewAnimationOptions.AllowUserInteraction), animations: { () -> Void in
                
                self.setFrameToBothAnchorView(ControlPoint)
                
                }, completion: { (finish) -> Void in
                    
                    self.curveType = CurveShape.SurfaceTensionPhaseIII
                    
                    UIView.animateWithDuration( NSTimeInterval(0.5) , delay: self.animationSpecs!.centerDelay, usingSpringWithDamping: CGFloat(0.3), initialSpringVelocity: self.animationSpecs!.centerVelocity, options: (.BeginFromCurrentState | .AllowUserInteraction) , animations: { () -> Void in
                        
                            self.setFrameToBothAnchorView(CGPointMake(0, 0))
                        
                        }, completion: { (finished) -> Void in
                            
                            self.displayLink?.invalidate()
                            self.displayLink = nil
                            self.isAnimating = false
                            self.hidden = true
                            
                            self.isAnimating = false
                            
//                            if onComplition != nil {
//                                onComplition?()
//                            }
                    })
            })
            
            
        //}
    }
    
    
    //MARK:- UTILITY METHODS
    func setAnimationSpecification(type:AnimationType){
        switch type {
            case .Normal :
                animationSpecs = Animation(
                    sideDelay : 0.1,
                    sideDumping : 0.4,
                    sideVelocity : 0.9,
                    centerDelay: 0.0,
                    centerDumping: 0.6,
                    centerVelocity: 0.6
                )
            case .Wave :
                animationSpecs = Animation(
                    sideDelay : 0.0,
                    sideDumping : 0.5,
                    sideVelocity : 0.5,
                    centerDelay : 0.1,
                    centerDumping : 0.5,
                    centerVelocity : 0.5
                )
            
        }
    }
    
    func setupAnimationSpecification() {
        // Direction Bouncing
        // Curve Type
        // AnimationSpecs
        // AnimatedObject
        // Fill Color
        
        // TASKS :: 
        // 1. Set CenterView
        // 2. Set SideView
        
        switch directionOfBouncing! {
            case .BottomInward :
                centerAnchorView = UIView(frame: CGRectMake(self.frame.size.width/2 - (MKAnchorViewDimension/2.0), self.frame.size.height - (MKAnchorViewDimension/2.0), MKAnchorViewDimension, MKAnchorViewDimension))
                sideAnchorView = UIView(frame: CGRectMake(0 - (MKAnchorViewDimension/2.0), self.frame.size.height - (MKAnchorViewDimension/2.0), MKAnchorViewDimension, MKAnchorViewDimension))
            
            case .TopInward :
                centerAnchorView = UIView(frame: CGRectMake(self.frame.size.width/2 - (MKAnchorViewDimension/2.0), 0 - (MKAnchorViewDimension/2.0), MKAnchorViewDimension, MKAnchorViewDimension))
                sideAnchorView = UIView(frame: CGRectMake(0 - (MKAnchorViewDimension/2.0), 0 - (MKAnchorViewDimension/2.0), MKAnchorViewDimension, MKAnchorViewDimension))
            
            case .SurfaceTension :
                centerAnchorView = UIView(frame: CGRectMake(self.frame.size.width/2 - (MKAnchorViewDimension/2.0), self.frame.size.height - (MKAnchorViewDimension/2.0), MKAnchorViewDimension, MKAnchorViewDimension))
                sideAnchorView = UIView(frame: CGRectMake(physicalObject!.x  - (MKAnchorViewDimension/2.0), self.frame.size.height - (MKAnchorViewDimension/2.0), MKAnchorViewDimension, MKAnchorViewDimension))
                
                // TODO:- SurfaceTension A few variable might be set here
            
            default:
                print("DirectionOfBouncing :: default")
        }
//        centerAnchorView?.backgroundColor = UIColor.greenColor()
//        sideAnchorView?.backgroundColor = UIColor.greenColor()

        //TODO:- Other Direction Of Bouncing yet to implement
    }
    
    
    func setFrameToBothAnchorView(controlPoint: CGPoint) {
        
        var heightOfControlPoint: CGFloat = self.frame.size.height - controlPoint.y
        var distXBetnPoints: CGFloat = heightOfControlPoint * 0.5
        var xOfSideAnchorView = controlPoint.x - distXBetnPoints
        
        var widthOfControlPoint: CGFloat = controlPoint.x
        var distYBetnPoints: CGFloat = widthOfControlPoint * 1.25
        var yOfSideAnchorView = controlPoint.y - distYBetnPoints
        
        switch directionOfBouncing! {
            case .SurfaceTensionLeftInward :
                switch curveType! {
                    case .SurfaceTensionPhase0 :
                        
                        self.centerAnchorView = UIView(frame: CGRectMake( 0 - (MKAnchorViewDimension/2.0), controlPoint.y - (MKAnchorViewDimension/2.0), MKAnchorViewDimension, MKAnchorViewDimension))
                        self.sideAnchorView = UIView(frame: CGRectMake(0 - (MKAnchorViewDimension/2.0), yOfSideAnchorView - (MKAnchorViewDimension/2.0), MKAnchorViewDimension, MKAnchorViewDimension))
                        
                    case .SurfaceTensionPhaseI :
                        
                        self.centerAnchorView?.frame = CGRectMake( controlPoint.x - (self.MKAnchorViewDimension/2.0), controlPoint.y - (self.MKAnchorViewDimension/2.0), self.MKAnchorViewDimension, self.MKAnchorViewDimension)
                        self.sideAnchorView?.frame = CGRectMake(0 - (self.MKAnchorViewDimension/2.0), yOfSideAnchorView - (self.MKAnchorViewDimension/2.0), self.MKAnchorViewDimension, self.MKAnchorViewDimension)
                        
                        
                    case .SurfaceTensionPhaseII :
                        
                        self.sideAnchorView?.frame = CGRectMake(0, self.centerAnchorView!.frame.origin.y, self.sideAnchorView!.frame.size.width, self.sideAnchorView!.frame.size.width)
                        
                        
                    case .SurfaceTensionPhaseIII :
                        
                        distXBetnPoints = self.centerAnchorView!.frame.origin.x - self.sideAnchorView!.frame.origin.x
                        
                        self.centerAnchorView?.frame = CGRectMake( 0 - (self.MKAnchorViewDimension/2.0), self.centerAnchorView!.frame.origin.y - (self.MKAnchorViewDimension/2.0), self.MKAnchorViewDimension, self.MKAnchorViewDimension)
                    
                    default :
                        print()
                }
            case .SurfaceTensionRightInward :
                switch curveType! {
                    case .SurfaceTensionPhase0 :
                        
                        widthOfControlPoint = self.frame.size.width - controlPoint.x
                        distYBetnPoints = widthOfControlPoint * 1.25
                        yOfSideAnchorView = controlPoint.y - distYBetnPoints
                        
                        self.centerAnchorView = UIView(frame: CGRectMake( self.frame.size.width - (MKAnchorViewDimension/2.0), controlPoint.y - (MKAnchorViewDimension/2.0), MKAnchorViewDimension, MKAnchorViewDimension))
                        self.sideAnchorView = UIView(frame: CGRectMake(self.frame.size.width - (MKAnchorViewDimension/2.0), yOfSideAnchorView - (MKAnchorViewDimension/2.0), MKAnchorViewDimension, MKAnchorViewDimension))
                        
                    case .SurfaceTensionPhaseI :
                        
                        widthOfControlPoint = self.frame.size.width - controlPoint.x
                        distYBetnPoints = widthOfControlPoint * 1.25
                        yOfSideAnchorView = controlPoint.y - distYBetnPoints
                        
                        self.centerAnchorView?.frame = CGRectMake( controlPoint.x - (self.MKAnchorViewDimension/2.0), controlPoint.y - (self.MKAnchorViewDimension/2.0), self.MKAnchorViewDimension, self.MKAnchorViewDimension)
                        self.sideAnchorView?.frame = CGRectMake(self.frame.size.width - (self.MKAnchorViewDimension/2.0), yOfSideAnchorView - (self.MKAnchorViewDimension/2.0), self.MKAnchorViewDimension, self.MKAnchorViewDimension)
                        
                        
                    case .SurfaceTensionPhaseII :
                        
                        self.sideAnchorView?.frame = CGRectMake(self.frame.size.width, self.centerAnchorView!.frame.origin.y, self.sideAnchorView!.frame.size.width, self.sideAnchorView!.frame.size.width)
                        
                        
                    case .SurfaceTensionPhaseIII :
                        
                        self.centerAnchorView?.frame = CGRectMake( self.frame.size.width - (self.MKAnchorViewDimension/2.0), self.centerAnchorView!.frame.origin.y - (self.MKAnchorViewDimension/2.0), self.MKAnchorViewDimension, self.MKAnchorViewDimension)
                        
                    default :
                        print()
                }
            case .SurfaceTensionTopInward :
                switch curveType! {
                    case .SurfaceTensionPhase0 :
                        
                        heightOfControlPoint = controlPoint.y
                        distXBetnPoints = heightOfControlPoint * 0.5
                        xOfSideAnchorView = controlPoint.x - distXBetnPoints
                        
                        self.centerAnchorView = UIView(frame: CGRectMake( controlPoint.x - (MKAnchorViewDimension/2.0), 0 - (MKAnchorViewDimension/2.0), MKAnchorViewDimension, MKAnchorViewDimension))
                        self.sideAnchorView = UIView(frame: CGRectMake(xOfSideAnchorView - (MKAnchorViewDimension/2.0), 0 - (MKAnchorViewDimension/2.0), MKAnchorViewDimension, MKAnchorViewDimension))
                    
                    case .SurfaceTensionPhaseI :
                        
                        heightOfControlPoint = controlPoint.y
                        distXBetnPoints = heightOfControlPoint * 0.5
                        xOfSideAnchorView = controlPoint.x - distXBetnPoints
                        
                        self.centerAnchorView?.frame = CGRectMake( controlPoint.x - (self.MKAnchorViewDimension/2.0), controlPoint.y - (self.MKAnchorViewDimension/2.0), self.MKAnchorViewDimension, self.MKAnchorViewDimension)
                        self.sideAnchorView?.frame = CGRectMake(xOfSideAnchorView - (self.MKAnchorViewDimension/2.0), 0 - (self.MKAnchorViewDimension/2.0), self.MKAnchorViewDimension, self.MKAnchorViewDimension)
                    
                    case .SurfaceTensionPhaseII :
                        
                        self.sideAnchorView?.frame = CGRectMake(self.centerAnchorView!.center.x, self.sideAnchorView!.frame.origin.y, self.sideAnchorView!.frame.size.width, self.sideAnchorView!.frame.size.width)
                        
                        
                    case .SurfaceTensionPhaseIII :
                        
                        self.centerAnchorView?.frame = CGRectMake(self.centerAnchorView!.frame.origin.x - (self.MKAnchorViewDimension/2.0), 0 - (self.MKAnchorViewDimension/2.0), self.MKAnchorViewDimension, self.MKAnchorViewDimension)
                        
                    default :
                        print()
                    }
                print()
            case .SurfaceTensionBottomInward :
                switch curveType! {
                    case .SurfaceTensionPhase0 :
                        
                        self.centerAnchorView = UIView(frame: CGRectMake( controlPoint.x - (MKAnchorViewDimension/2.0), self.frame.size.height - (MKAnchorViewDimension/2.0), MKAnchorViewDimension, MKAnchorViewDimension))
                        self.sideAnchorView = UIView(frame: CGRectMake(xOfSideAnchorView - (MKAnchorViewDimension/2.0), self.frame.size.height - (MKAnchorViewDimension/2.0), MKAnchorViewDimension, MKAnchorViewDimension))
                        
                    case .SurfaceTensionPhaseI :
                       
                        self.centerAnchorView?.frame = CGRectMake( controlPoint.x - (self.MKAnchorViewDimension/2.0), controlPoint.y - (self.MKAnchorViewDimension/2.0), self.MKAnchorViewDimension, self.MKAnchorViewDimension)
                        self.sideAnchorView?.frame = CGRectMake(xOfSideAnchorView - (self.MKAnchorViewDimension/2.0), self.frame.size.height - (self.MKAnchorViewDimension/2.0), self.MKAnchorViewDimension, self.MKAnchorViewDimension)
                        
                        
                    case .SurfaceTensionPhaseII :
                        
                        self.sideAnchorView?.frame = CGRectMake(self.centerAnchorView!.center.x, self.sideAnchorView!.frame.origin.y, self.sideAnchorView!.frame.size.width, self.sideAnchorView!.frame.size.width)
                        
                        
                    case .SurfaceTensionPhaseIII :
                        
                        self.centerAnchorView?.frame = CGRectMake(self.centerAnchorView!.frame.origin.x - (self.MKAnchorViewDimension/2.0), self.frame.size.height - (self.MKAnchorViewDimension/2.0), self.MKAnchorViewDimension, self.MKAnchorViewDimension)
                    
                    default :
                        print()
                }
            default :
                print()
            }
            
    }
    
    func getFrameForBothViews(isOpening: Bool) {

        //TODO:- Other Direction Of Bouncing : Proper frame need to be set

        if isOpening {
            switch directionOfBouncing! {
                case .BottomInward :
                    centerAnchorView?.frame = CGRectMake(self.frame.size.width/2, 0, MKAnchorViewDimension, MKAnchorViewDimension)
                case .TopInward :
                    centerAnchorView?.frame = CGRectMake(self.frame.size.width/2, self.frame.size.height, MKAnchorViewDimension, MKAnchorViewDimension)
                case .SurfaceTension :
                    centerAnchorView?.frame = CGRectMake(self.frame.size.width/2 - (MKAnchorViewDimension/2.0), self.frame.size.height * 0.20 - (MKAnchorViewDimension/2.0), MKAnchorViewDimension, MKAnchorViewDimension)
                    sideAnchorView?.frame = CGRectMake(physicalObject!.x - physicalObject!.width/2.0 - (MKAnchorViewDimension/2.0), self.frame.size.height - (MKAnchorViewDimension/2.0), MKAnchorViewDimension, MKAnchorViewDimension)
                default:
                    print("DirectionOfBouncing :: default")
            }

        } else {
            switch directionOfBouncing! {
                case .BottomInward :
                    centerAnchorView?.frame = CGRectMake(self.frame.size.width/2, self.frame.size.height, MKAnchorViewDimension, MKAnchorViewDimension)
                case .TopInward :
                    centerAnchorView?.frame = CGRectMake(self.frame.size.width/2, 0, MKAnchorViewDimension, MKAnchorViewDimension)
                case .SurfaceTension :
                    // TODO:- SurfaceTension Y of centerAnchorView might be changed.
                    centerAnchorView?.frame = CGRectMake(self.frame.size.width/2 - (MKAnchorViewDimension/2.0), self.frame.size.height - (MKAnchorViewDimension/2.0), MKAnchorViewDimension, MKAnchorViewDimension)
                
                default:
                    print("DirectionOfBouncing :: default")
            }
        }
        
    }
    
    func getPathAccordingToCurveShape(curveShape: CurveShape, direction: DirectionOfBouncing) -> UIBezierPath {
        
        let path = UIBezierPath()
        
        // Get Proper Center For SidePoint & ControlPoint
        let sideLayer: CALayer? = sideAnchorView!.layer.presentationLayer() as? CALayer
        let centerLayer: CALayer? = centerAnchorView!.layer.presentationLayer() as? CALayer
        
        var sideLayerControlPoint = CGPointMake(0.0, 0.0)
        var centerLayerControlPoint = CGPointMake(0.0, 0.0)
        
        // When it is called for first time, it is nil. So, this checking is added
        if sideLayer != nil {
            sideLayerControlPoint = CGPointMake(sideLayer!.frame.origin.x + sideLayer!.frame.size.width/2.0, sideLayer!.frame.origin.y + CGFloat(sideLayer!.frame.size.height/2.0))
            centerLayerControlPoint = CGPointMake(centerLayer!.frame.origin.x + centerLayer!.frame.size.width/2.0, centerLayer!.frame.origin.y + CGFloat(centerLayer!.frame.size.height/2.0))
        }
        
        var distXBetnPoints: CGFloat = centerLayerControlPoint.x - sideLayerControlPoint.x
        var distYBetnPoints: CGFloat = centerLayerControlPoint.y - sideLayerControlPoint.y
        var destinationPointHorizontally: CGPoint = CGPointMake(sideLayerControlPoint.x + 2.0 * distXBetnPoints , sideLayerControlPoint.y)
        var destinationPointVertically: CGPoint = CGPointMake(sideLayerControlPoint.x , sideLayerControlPoint.y + 2.0 * distYBetnPoints)
        
        
        switch direction {
            case .BottomInward :
                switch curveShape {
                    case .Arc :
                        path.moveToPoint(sideLayerControlPoint)
                        path.addQuadCurveToPoint(CGPointMake(sideLayerControlPoint.x + self.frame.size.width , sideLayerControlPoint.y), controlPoint: centerLayerControlPoint)
                        path.closePath()
                    
                    case .EggShape :
                        var a: CGPoint = CGPointMake(centerLayerControlPoint.x/4.0, centerLayerControlPoint.y)
                        var b: CGPoint = CGPointMake(centerLayerControlPoint.x*1.75, centerLayerControlPoint.y)
                        
                        path.moveToPoint(sideLayerControlPoint)
                        path.addCurveToPoint(destinationPointHorizontally, controlPoint1: a, controlPoint2: b)
                        path.closePath()

                    default:
                        print("")
                }
            case .TopInward :
                switch curveShape {
                case .Arc :
                    print("")
                case .EggShape :
                    print("")
                default:
                    print("")
                }
            
            case .SurfaceTensionBottomInward , .SurfaceTensionTopInward :
                switch curveShape {
                    case .Arc :
                        print("")
                    case .EggShape :
                        print("")
                    case .RoundTrigonal :
                        print("")
                    case .SurfaceTensionPhaseI :
                        
                        
                        var controlPointForCenter1: CGPoint = CGPointMake( sideLayerControlPoint.x + distXBetnPoints * 0.60, centerLayerControlPoint.y )
                        var controlPointForCenter2: CGPoint = CGPointMake(centerLayerControlPoint.x + distXBetnPoints * 0.40, centerLayerControlPoint.y)
                        var controlPointForLeftSide: CGPoint = CGPointMake(sideLayerControlPoint.x + distXBetnPoints * 0.3, sideLayerControlPoint.y)
                        var controlPointForRightSide: CGPoint = CGPointMake(destinationPointHorizontally.x - distXBetnPoints * 0.3, sideLayerControlPoint.y)
                        
                        
                        path.moveToPoint(sideLayerControlPoint)
                        path.addCurveToPoint(centerLayerControlPoint, controlPoint1: controlPointForLeftSide, controlPoint2: controlPointForCenter1)
                        path.addCurveToPoint(destinationPointHorizontally, controlPoint1: controlPointForCenter2, controlPoint2: controlPointForRightSide)
                        path.closePath()
                    
                    case .SurfaceTensionPhaseII :
                        
                        distXBetnPoints = centerLayerControlPoint.x - sideAnchorViewHolder!.x
                        destinationPointHorizontally = CGPointMake(centerLayerControlPoint.x + distXBetnPoints, sideAnchorViewHolder!.y)
                        var distXBetnCenterAndMovingSidePoints: CGFloat = centerLayerControlPoint.x - sideLayerControlPoint.x
                        var controlPointForCenter1: CGPoint = CGPointMake( sideAnchorViewHolder!.x + distXBetnPoints * 0.70, centerLayerControlPoint.y )
                        var controlPointForCenter2: CGPoint = CGPointMake(centerLayerControlPoint.x + distXBetnPoints * 0.30, centerLayerControlPoint.y)
                        
                        var controlPointForLeftSide: CGPoint = CGPointMake( sideLayerControlPoint.x + distXBetnCenterAndMovingSidePoints * 0.3 , sideLayerControlPoint.y)
                        var controlPointForRightSide: CGPoint = CGPointMake( centerLayerControlPoint.x + distXBetnCenterAndMovingSidePoints * 0.7, sideLayerControlPoint.y)
                        
                    
                        path.moveToPoint(sideAnchorViewHolder!)
                        path.addCurveToPoint(centerLayerControlPoint, controlPoint1: sideLayerControlPoint, controlPoint2: controlPointForCenter1)
                        path.addCurveToPoint(destinationPointHorizontally, controlPoint1: controlPointForCenter2, controlPoint2: controlPointForRightSide)
                        path.closePath()
                    
                    
                    case .SurfaceTensionPhaseIII :
                        
                        distXBetnPoints = centerLayerControlPoint.x - sideAnchorViewHolder!.x
                        destinationPointHorizontally = CGPointMake(centerLayerControlPoint.x + distXBetnPoints, sideAnchorViewHolder!.y)
                        var controlPointForCenter1: CGPoint = CGPointMake( sideAnchorViewHolder!.x + distXBetnPoints * 0.70, centerLayerControlPoint.y )
                        var controlPointForCenter2: CGPoint = CGPointMake(centerLayerControlPoint.x + distXBetnPoints * 0.30, centerLayerControlPoint.y)
                        
                        path.moveToPoint(sideAnchorViewHolder!)
                        path.addCurveToPoint(centerLayerControlPoint, controlPoint1: sideLayerControlPoint, controlPoint2: controlPointForCenter1)
                        path.addCurveToPoint(destinationPointHorizontally, controlPoint1: controlPointForCenter2, controlPoint2: sideLayerControlPoint)
                        path.closePath()
                    
                    default:
                        print("")
                }
            
            case .SurfaceTensionLeftInward, .SurfaceTensionRightInward:
                switch curveShape {
                    
                    case .Arc :
                        print("")
                    case .EggShape :
                        print("")
                    case .RoundTrigonal :
                        print("")
                    case .SurfaceTensionPhaseI :
                        
                        
                        var controlPointForCenter1: CGPoint = CGPointMake( centerLayerControlPoint.x , centerLayerControlPoint.y - distYBetnPoints * 0.40 )
                        var controlPointForCenter2: CGPoint = CGPointMake( centerLayerControlPoint.x , centerLayerControlPoint.y + distYBetnPoints * 0.40 )
                        
                        var controlPointForLeftSide: CGPoint = CGPointMake(sideLayerControlPoint.x , sideLayerControlPoint.y + distYBetnPoints * 0.3)
                        var controlPointForRightSide: CGPoint = CGPointMake(sideLayerControlPoint.x , destinationPointVertically.y - distYBetnPoints * 0.3)
                        
                        path.moveToPoint(sideLayerControlPoint)
                        path.addCurveToPoint(centerLayerControlPoint, controlPoint1: controlPointForLeftSide, controlPoint2: controlPointForCenter1)
                        path.addCurveToPoint(destinationPointVertically, controlPoint1: controlPointForCenter2, controlPoint2: controlPointForRightSide)
                        path.closePath()
                        
                    case .SurfaceTensionPhaseII :
                        
                        distYBetnPoints = centerLayerControlPoint.y - sideAnchorViewHolder!.y
                        
                        destinationPointVertically = CGPointMake( sideAnchorViewHolder!.x , sideAnchorViewHolder!.y + 2.0 * distYBetnPoints )
                        
                        var distYBetnCenterAndMovingSidePoints: CGFloat = centerLayerControlPoint.y - sideLayerControlPoint.y
                        
                        var controlPointForCenter1: CGPoint = CGPointMake( centerLayerControlPoint.x , centerLayerControlPoint.y - distYBetnPoints * 0.30 )
                        var controlPointForCenter2: CGPoint = CGPointMake( centerLayerControlPoint.x , centerLayerControlPoint.y + distYBetnPoints * 0.30 )
                        
                        var controlPointForLeftSide: CGPoint = CGPointMake(sideLayerControlPoint.x , sideLayerControlPoint.y + distYBetnCenterAndMovingSidePoints * 0.4)
                        var controlPointForRightSide: CGPoint = CGPointMake(sideLayerControlPoint.x , centerLayerControlPoint.y + distYBetnCenterAndMovingSidePoints * 0.6)
                        
                        
                        path.moveToPoint(sideAnchorViewHolder!)
                        path.addCurveToPoint(centerLayerControlPoint, controlPoint1: sideLayerControlPoint, controlPoint2: controlPointForCenter1)
                        path.addCurveToPoint(destinationPointVertically, controlPoint1: controlPointForCenter2, controlPoint2: controlPointForRightSide)
                        path.closePath()
                        
                        
                    case .SurfaceTensionPhaseIII :
                        
                        distYBetnPoints = centerLayerControlPoint.y - sideAnchorViewHolder!.y
                        destinationPointVertically = CGPointMake(sideAnchorViewHolder!.x , sideAnchorViewHolder!.y + 2.0 * distYBetnPoints)
                        var controlPointForCenter1: CGPoint = CGPointMake( centerLayerControlPoint.x , sideAnchorViewHolder!.y + distYBetnPoints * 0.70 )
                        var controlPointForCenter2: CGPoint = CGPointMake(centerLayerControlPoint.x , centerLayerControlPoint.y +  distYBetnPoints * 0.30)
                        
                        path.moveToPoint(sideAnchorViewHolder!)
                        path.addCurveToPoint(centerLayerControlPoint, controlPoint1: sideLayerControlPoint, controlPoint2: controlPointForCenter1)
                        path.addCurveToPoint(destinationPointVertically, controlPoint1: controlPointForCenter2, controlPoint2: sideLayerControlPoint)
                        path.closePath()
                        
                    default:
                        print("")
                }
            
            
            default:
                print("Something wrong drawing Path")
            
        }
        
        return path
    }
    
    func updateDisplay(displayLink:CADisplayLink) {
        self.setNeedsDisplay()
        //println("updateDisplay")
    }
}

    
    
    