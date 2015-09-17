//
//  ViewController.swift
//  Animation
//
//  Created by Milan Kamilya on 14/09/15.
//  Copyright (c) 2015 innofied. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var shapeButton: UIButton!
    @IBOutlet weak var shapeButton2: UIButton!
    @IBOutlet weak var shapeButton3: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.giveShapeToButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func giveShapeToButtons() {
        
        // 1
        shapeButton.layer.cornerRadius = 20
        
        // 2
        let shapeLayer2 = CAShapeLayer()
        shapeLayer2.fillColor = UIColor.greenColor().CGColor
        shapeLayer2.bounds = shapeButton2.bounds
        shapeLayer2.position = CGPointMake(shapeButton2.bounds.width/2, shapeButton2.bounds.height/2)
        shapeLayer2.path = UIBezierPath(roundedRect: shapeLayer2.bounds, cornerRadius: 15).CGPath
        shapeButton2.layer.addSublayer(shapeLayer2)
        
        // 3
        let shapeLayer3 = CAShapeLayer()
        shapeLayer3.fillColor = UIColor.redColor().CGColor
        shapeLayer3.bounds = shapeButton3.bounds
        shapeLayer3.position = CGPointMake(shapeButton3.bounds.width/2, shapeButton3.bounds.height/2)
        shapeLayer3.anchorPoint = CGPointMake(1.0, 1.0)
        //shapeLayer3.path = UIBezierPath(roundedRect: shapeLayer3.bounds, byRoundingCorners: .TopLeft | .TopRight | .BottomLeft , cornerRadii: CGSizeMake(15, 15)).CGPath
        shapeButton3.layer.addSublayer(shapeLayer3)
        
        
        let animation = CABasicAnimation(keyPath: "transform")
        animation.duration = 3.0
        //let scale = CATransform3DMakeScale(3.0, 2.0, 0.5)
        
        animation.toValue = NSValue(CATransform3D: CATransform3DMakeScale(3.0, 2.0, 1.0))
        
        shapeLayer3.addAnimation(animation, forKey: "transform")
        shapeLayer3.path = UIBezierPath(roundedRect: shapeLayer3.bounds, byRoundingCorners: .TopLeft | .TopRight | .BottomLeft , cornerRadii: CGSizeMake(15, 15)).CGPath
    }
    

}

