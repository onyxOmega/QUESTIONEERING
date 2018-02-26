//
//  MapViewController.swift
//  Main_Project
//
//  Created by William Fischer on 2/7/18.
//  Copyright © 2018 QUESTIONEERING. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var processFeedbackLabel: UILabel!

    var session: Session!
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        scrollView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print(session.loginStatus)
        
        let activeMap = QRMap(withMapID: 0, forSession: session)
        print("Active Map: \(activeMap)")
        
        if let tree = activeMap.tree{
            drawMap(withRoot: tree)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func drawMap(withRoot root: QRNode){
        
        
        let rootNodeButton = NodeButton(xPos: 100, yPos: Double(view.frame.height/2), node: root)
        rootNodeButton.addTarget(self, action: #selector(nodeSoftFocus), for: .touchUpInside)
        mapContainerView.addSubview(rootNodeButton)
        
        scrollView.minimumZoomScale = 0.9
        scrollView.maximumZoomScale = 1.1
    }
    
   
    
    @objc func nodeSoftFocus(_ sender: NodeButton){
        print(sender.nodeType)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        label.center = CGPoint(x: sender.xPos + 20, y: sender.yPos + 65)
        label.textAlignment = .center
        label.text = sender.nodeTitle
        label.layer.cornerRadius = label.frame.height/2
        label.layer.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        label.alpha = 0.5
        sender.superview?.addSubview(label)
    }
}




extension MapViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.mapContainerView
    }
    
}
