//
//  DesignableView.swift
//  Main_Project
//
//  Created by Trystan Kaes on 2/28/18.
//  Copyright © 2018 QUESTIONEERING. All rights reserved.
//

import UIKit

@IBDesignable class DesignableView: UIView {

    
    
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
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
