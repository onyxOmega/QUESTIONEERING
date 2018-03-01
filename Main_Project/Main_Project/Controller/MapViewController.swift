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
        
        
        if let cartographer = QRCartographer(map: activeMap) {
            drawMap(with: cartographer)
        }
        else{
            print("The map is invalid! (Need some debugging)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func drawMap(with cartographer: QRCartographer){
        
        var nodeButtons : [NodeButton] = []
        
        for node in cartographer.displayableNodes{
            let newNodeButton = NodeButton(yCenter: Double(view.frame.height/2), node: node)
            newNodeButton.addTarget(self, action: #selector(nodeSoftFocus), for: .touchUpInside)
            nodeButtons.append(newNodeButton)
            mapContainerView.addSubview(newNodeButton)
        }
        
        // let edge = Edge(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        // mapContainerView.addSubview(edge)
        
        scrollView.minimumZoomScale = 0.9
        scrollView.maximumZoomScale = 1.1
    }
    
   
    
    @objc func nodeSoftFocus(_ sender: NodeButton){
        print(sender.nodeType)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 130, height: 30))
        label.center = CGPoint(x: sender.xPos + 15, y: sender.yPos + 55)
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
