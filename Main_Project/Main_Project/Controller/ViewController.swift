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

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    
    override func loadView() {
        super.loadView()
        print(session)
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        self.signInButton.backgroundColor = .clear
        signInButton.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        signInButton.layer.borderWidth = 1.5
        
        usernameTextField.borderStyle = .none
        passwordTextField.borderStyle = .none
        
        usernameTextField.attributedPlaceholder = NSAttributedString(string: "username", attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0.5)])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0.5)])

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func signIn(_ sender: Any) {
        let sessionUser = session.loginUser(withEmail: usernameTextField.text!, withPassword: passwordTextField.text!)
        welcomeLabel.text = "Hello, \(sessionUser.firstName!)!"
    }
}
