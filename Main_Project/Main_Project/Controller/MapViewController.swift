//
//  ProfileViewController.swift
//  Main_Project
//
//  Created by William Fischer on 2/7/18.
//  Copyright © 2018 QUESTIONEERING. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {
    
    
    override func loadView() {
        super.loadView()
        
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let activeMap = session.getQRMap(mID: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
