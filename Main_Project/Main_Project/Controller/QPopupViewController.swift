//
//  QPopupViewControllera.swift
//  Main_Project
//
//  Created by Trystan Kaes on 3/3/18.
//  Copyright © 2018 QUESTIONEERING. All rights reserved.
//

import UIKit

class QPopupViewController: UIViewController {
    @IBOutlet weak var questionField: UITextField!
    @IBOutlet weak var synopsisField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    var node: QRNode!
    var location: CGRect!
    
    override func viewDidLoad() {
        if (node?.title) != nil{
           questionField.text = node.title
           print("title unwrapped")
        }
        if (node?.detail) != nil{
           synopsisField.text = node.detail
            print("detail unwrapped")
        }
        //TODO: Where is the dateField?
//        dateField.text = node.type
    }
    
    
    
}
