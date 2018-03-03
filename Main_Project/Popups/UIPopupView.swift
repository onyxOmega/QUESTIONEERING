//
//  PopupViewController.swift
//  Main_Project
//
//  Created by Trystan Kaes on 2/28/18.
//  Copyright © 2018 QUESTIONEERING. All rights reserved.
//

import Foundation
import UIKit


class UiPopupView : UIView {
    var view: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        xibSetup()
    }
    
    
}





private extension UiPopupView {
    /* Setup the nib with correct constraints and presentation */
    func xibSetup(){
        backgroundColor = UIColor.clear
        view = loadNib()
        
        view.frame = bounds
        
        addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H: | [childView]|",
            options: [],
            metrics: nil,
            views: ["childView" : view])        )
    }
    
}



//--------------------

extension UIView {
    /*Derive a UIView from custom xib file*/
    func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
}


//class Qpopup : UIView {
//
//    @IBOutlet weak var question: UITextField!
//    @IBOutlet weak var synopsis: UITextField!
//    @IBOutlet weak var date: UITextField!
//
//
//    required init(node: QRNode) {
//        // set myValue before super.init is called
//        self.xPos = gridPosition.x
//        self.yPos = yPos
//
//        self.question = node.title
//        self.synopsis = node.detail
//
//        super.init(frame: CGRect(x: xPos, y: yPos, width: 30, height: 30))
//    }
//
//
//
//    @IBAction func closeEdit(_ sender: UIButton) {
//        dismiss(animated: true, completion: nil)
//    }
//
//
//     func popIt(_ rect: CGRect) {
//        guard let context = UIGraphicsGetCurrentContext() else { return }
//        let rectangle = bounds.insetBy(dx: strokeWidth / 2, dy: strokeWidth / 2)
//
//        context.setFillColor(fillColor.cgColor)
//        context.setStrokeColor(strokeColor.cgColor)
//        context.setLineWidth(strokeWidth)
//
//        context.addEllipse(in: rectangle)
//        context.drawPath(using: .fillStroke)
//    }


    
//}

