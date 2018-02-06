//
//  ViewController.swift
//  Main_Project
//
//  Created by Trystan Kaes on 2/4/18.
//  Copyright © 2018 QUESTIONEERING. All rights reserved.
//

import UIKit

let session = SManager()

class ViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func loadView() {
        super.loadView()
        print(session)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginButton(_ sender: Any) {
        _ = session.loginUser(withEmail: email.text!, withPassword: password.text!)
    }
}
