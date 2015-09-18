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
    case SurfaceTensionOutward
    case SurfaceTensionInward
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
}

class MKFluidView: UIView {
    
    //MARK:- CONSTANTS
    let MGSideHelperView: CGFloat = 2.0
    
    //MARK:- PUBLIC PROPERTIES
    var directionOfBouncing: DirectionOfBouncing? = .BottomInward
    var curveType: CurveShape? = .Arc
    var animationSpecs: Animation? = Animation( sideDelay : 0.1, sideDumping : 0.4, sideVelocity : 0.9, centerDelay: 0.0, centerDumping: 0.6, centerVelocity: 0.6 )
    var animatedObject: AnimatedObject? = .Both
    var fillColor: UIColor? = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
    var animationDuration: NSTimeInterval? = 0.5
    
    /// Set this property if you want to have object & Surface tension animation
    var physicalObject: PhysicalObject? = PhysicalObject(x: 100, y: 0, width: 100, height: 50, roundRect: 0)
    
    
    //MARK:- PRIVATE PROPERTIES
    private var isShown: Bool? = false
    private var isAnimating: Bool? = false
    private var displayLink: CADisplayLink? = nil
    
    private var menuView: UIView?
    private var centerAnchorView: UIView?
    private var sideAnchorView: UIView?
    
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
        
        
        sideAnchorView = UIView(frame:CGRectMake(CGFloat(-MGSideHelperView/2.0), self.frame.height + CGFloat( -MGSideHelperView/2.0), CGFloat(MGSideHelperView), CGFloat(MGSideHelperView)))
        sideAnchorView?.backgroundColor = UIColor.greenColor()
        centerAnchorView = UIView(frame:CGRectMake(CGFloat(self.frame.size.width/2.0)-MGSideHelperView/2.0, self.frame.size.height + CGFloat(-MGSideHelperView/2.0), CGFloat(MGSideHelperView), CGFloat(MGSideHelperView)))
        centerAnchorView?.backgroundColor = UIColor.greenColor()
        
    }

    //MARK:- DRAWING
    override func drawRect(rect: CGRect) {
        
        if sideAnchorView?.superview == nil {
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
                centerAnchorView = UIView(frame: CGRectMake(self.frame.size.width/2 - (MGSideHelperView/2.0), self.frame.size.height - (MGSideHelperView/2.0), MGSideHelperView, MGSideHelperView))
                sideAnchorView = UIView(frame: CGRectMake(0 - (MGSideHelperView/2.0), self.frame.size.height - (MGSideHelperView/2.0), MGSideHelperView, MGSideHelperView))
            case .TopInward :
                centerAnchorView = UIView(frame: CGRectMake(self.frame.size.width/2 - (MGSideHelperView/2.0), 0 - (MGSideHelperView/2.0), MGSideHelperView, MGSideHelperView))
                sideAnchorView = UIView(frame: CGRectMake(0 - (MGSideHelperView/2.0), 0 - (MGSideHelperView/2.0), MGSideHelperView, MGSideHelperView))
            
            case .SurfaceTension :
                centerAnchorView = UIView(frame: CGRectMake(self.frame.size.width/2 - (MGSideHelperView/2.0), self.frame.size.height - (MGSideHelperView/2.0), MGSideHelperView, MGSideHelperView))
                sideAnchorView = UIView(frame: CGRectMake(physicalObject!.x  - (MGSideHelperView/2.0), self.frame.size.height - (MGSideHelperView/2.0), MGSideHelperView, MGSideHelperView))
                
                // TODO:- SurfaceTension A few variable might be set here
            
            default:
                print("DirectionOfBouncing :: default")
        }
        centerAnchorView?.backgroundColor = UIColor.greenColor()
        sideAnchorView?.backgroundColor = UIColor.greenColor()

        //TODO:- Other Direction Of Bouncing yet to implement
    }
    
    
    func getFrameForBothViews(isOpening: Bool) {

        //TODO:- Other Direction Of Bouncing : Proper frame need to be set

        if isOpening {
            switch directionOfBouncing! {
                case .BottomInward :
                    centerAnchorView?.frame = CGRectMake(self.frame.size.width/2, 0, MGSideHelperView, MGSideHelperView)
                case .TopInward :
                    centerAnchorView?.frame = CGRectMake(self.frame.size.width/2, self.frame.size.height, MGSideHelperView, MGSideHelperView)
                case .SurfaceTension :
                    centerAnchorView?.frame = CGRectMake(self.frame.size.width/2 - (MGSideHelperView/2.0), 0 - (MGSideHelperView/2.0), MGSideHelperView, MGSideHelperView)
                    sideAnchorView?.frame = CGRectMake(physicalObject!.x - physicalObject!.width/2.0 - (MGSideHelperView/2.0), self.frame.size.height - (MGSideHelperView/2.0), MGSideHelperView, MGSideHelperView)
                    curveType = .SurfaceTensionOutward
                default:
                    print("DirectionOfBouncing :: default")
            }

        } else {
            switch directionOfBouncing! {
                case .BottomInward :
                    centerAnchorView?.frame = CGRectMake(self.frame.size.width/2, self.frame.size.height, MGSideHelperView, MGSideHelperView)
                case .TopInward :
                    centerAnchorView?.frame = CGRectMake(self.frame.size.width/2, 0, MGSideHelperView, MGSideHelperView)
                case .SurfaceTension :
                    // TODO:- SurfaceTension Y of centerAnchorView might be changed.
                    centerAnchorView?.frame = CGRectMake(self.frame.size.width/2 - (MGSideHelperView/2.0), self.frame.size.height - (MGSideHelperView/2.0), MGSideHelperView, MGSideHelperView)
                    sideAnchorView?.frame = CGRectMake(physicalObject!.x + physicalObject!.width/2.0 - (MGSideHelperView/2.0), self.frame.size.height - (MGSideHelperView/2.0), MGSideHelperView, MGSideHelperView)
                    curveType = .SurfaceTensionInward
                default:
                    print("DirectionOfBouncing :: default")
            }
        }
        
    }
    
    func getPathAccordingToCurveShape(curveShape: CurveShape, direction: DirectionOfBouncing) -> UIBezierPath {
        
        let path = UIBezierPath()
        
        // Get Proper Center For SidePoint & CenterPoint
        let sideLayer: CALayer? = sideAnchorView!.layer.presentationLayer() as? CALayer
        let centerLayer: CALayer? = centerAnchorView!.layer.presentationLayer() as? CALayer
        
        var sideLayerCenterPoint = CGPointMake(0.0, 0.0)
        var centerLayerCenterPoint = CGPointMake(0.0, 0.0)
        
        // When it is called for first time, it is nil. So, this checking is added
        if sideLayer != nil {
            sideLayerCenterPoint = CGPointMake(sideLayer!.frame.origin.x + sideLayer!.frame.size.width/2.0, sideLayer!.frame.origin.y + CGFloat(sideLayer!.frame.size.height/2.0))
            centerLayerCenterPoint = CGPointMake(centerLayer!.frame.origin.x + centerLayer!.frame.size.width/2.0, centerLayer!.frame.origin.y + CGFloat(centerLayer!.frame.size.height/2.0))
        }
        var distXBetnPoints: CGFloat = centerLayerCenterPoint.x - sideLayerCenterPoint.x
        var distYBetnPoints: CGFloat = centerLayerCenterPoint.y - sideLayerCenterPoint.y
        var destinationPoint: CGPoint = CGPointMake(sideLayerCenterPoint.x + 2.0 * distXBetnPoints , sideLayerCenterPoint.y)
        
        
        switch direction {
            case .BottomInward :
                switch curveShape {
                    case .Arc :
                        path.moveToPoint(sideLayerCenterPoint)
                        path.addQuadCurveToPoint(CGPointMake(sideLayerCenterPoint.x + self.frame.size.width , sideLayerCenterPoint.y), controlPoint: centerLayerCenterPoint)
                        path.closePath()
                    
                    case .EggShape :
                        var a: CGPoint = CGPointMake(centerLayerCenterPoint.x/4.0, centerLayerCenterPoint.y)
                        var b: CGPoint = CGPointMake(centerLayerCenterPoint.x*1.75, centerLayerCenterPoint.y)
                        
                        path.moveToPoint(sideLayerCenterPoint)
                        path.addCurveToPoint(destinationPoint, controlPoint1: a, controlPoint2: b)
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
            
            case .SurfaceTension :
                switch curveShape {
                    case .Arc :
                        print("")
                    case .EggShape :
                        print("")
                    case .RoundTrigonal :
                        print("")
                    case .SurfaceTensionInward :
                        // TODO:- Surface Tension Outward curve section
                        var midOfCenterPoint = CGPoint(x: centerLayerCenterPoint.x, y: CGFloat(centerLayerCenterPoint.y * 2))
                        var controlPoint1: CGPoint = CGPoint(x: sideLayerCenterPoint.x - 100, y: distYBetnPoints/2.0)
                        var controlPoint2: CGPoint = CGPoint(x: centerLayerCenterPoint.x, y: CGFloat(centerLayerCenterPoint.y * 1.75))
                        var controlPoint3: CGPoint = CGPoint(x: sideLayerCenterPoint.x + 2.0 * distXBetnPoints + 100, y: distYBetnPoints/2.0)
                        
                        println("SurfaceTensionInward :: \(controlPoint1), \(controlPoint2), \(controlPoint3)")
                        
                        path.moveToPoint(sideLayerCenterPoint)
                        path.addCurveToPoint(midOfCenterPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
                        path.addCurveToPoint(destinationPoint, controlPoint1: controlPoint2, controlPoint2: controlPoint3)
                        path.closePath()
                    
                    case .SurfaceTensionOutward :
                        path.moveToPoint(sideLayerCenterPoint)
                        path.addQuadCurveToPoint(destinationPoint, controlPoint: centerLayerCenterPoint)
                        path.closePath()
                    
                    default:
                        print("")
                }
            default :
                print("")
        }
        
        return path
    }
    
    func updateDisplay(displayLink:CADisplayLink) {
        self.setNeedsDisplay()
        //println("updateDisplay")
    }
}

    
    
    