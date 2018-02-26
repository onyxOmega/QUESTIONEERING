//
//  ViewController.swift
//  Main_Project
//
//  Created by Trystan Kaes on 2/4/18.
//  Copyright © 2018 QUESTIONEERING. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let session = Session()
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var loginError: UILabel!
    
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
        
        switch session.loginUser(withUsername: usernameTextField.text!, withPassword: passwordTextField.text!){
            
        case .loggedOut:
            self.loginError.text = "Sorry, the user name and password you provided are invalid."
            
        case .loggedInAs(_):
            let mapViewController = self.storyboard?.instantiateViewController(withIdentifier: "mapViewController") as! MapViewController
            mapViewController.session = self.session
            self.present(mapViewController, animated: true, completion: nil)
        }
       
    }
}
