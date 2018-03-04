//
//  RPopupViewController.swift
//  Main_Project
//
//  Created by Trystan Kaes on 3/4/18.
//  Copyright © 2018 QUESTIONEERING. All rights reserved.
//

import UIKit

class RPopupViewController: UIViewController {
        @IBOutlet weak var URLfield: UITextField!
        @IBOutlet weak var notesField: UITextField!
        @IBOutlet weak var dateField: UITextField!
        
        @IBOutlet weak var saveButton: UIButton!
        
        var node: QRNode!
        var location: CGRect!
        
        override func viewDidLoad() {
            if (node?.title) != nil{
                URLfield.text = node.title
                print("title unwrapped")
            }
            if (node?.detail) != nil{
                notesField.text = node.detail
                print("detail unwrapped")
            }
            //TODO: Where is the dateField?
            //        dateField.text = node.type
        }
        
}
