//
//  DesignableButton.swift
//  Main_Project
//
//  Created by Trystan Kaes on 3/1/18.
//  Copyright © 2018 QUESTIONEERING. All rights reserved.
//

import UIKit

class DesignableButton: UIButton {

    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var shadowColor: CGColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1){
        didSet {
            self.layer.shadowColor = shadowColor
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0 {
        didSet {
            self.layer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable var shadowRadius: Float = 0 {
        didSet {
            self.layer.shadowRadius = CGFloat(shadowRadius)
        }
    }
    
    @IBInspectable var shadowOffset: CGSize = CGSize(width: 0.0, height: 0.0) {
        didSet {
            self.layer.shadowOpacity = shadowOpacity
        }
    }
    

    
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
