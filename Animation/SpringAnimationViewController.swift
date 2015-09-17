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
    
    //MARK:- STORYBOARD COMPONENT
    @IBOutlet weak var textViewForMessagingText: UITextView!
    @IBOutlet weak var viewAtBackOfMessagingText: UIView!
    
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
        var menuView = UIView(frame: CGRectMake(0, 100, 320, 60))
        menuView.backgroundColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        springView = MKFluidView(frame: CGRectMake(0, 100, 320, 60))
        self.view.addSubview(springView!)
        
        springView?.animate(true, callback: { () -> Void in
            self.springView?.removeFromSuperview()
            self.springView = nil
        })
        
    }
    
    //MARK:- CUSTOM VIEW
    
    //MARK:- UTILITY METHODS
    


}
