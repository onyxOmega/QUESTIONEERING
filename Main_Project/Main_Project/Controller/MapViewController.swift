//
//  MapViewController.swift
//  Main_Project
//
//  Created by William Fischer on 2/7/18.
//  Copyright © 2018 QUESTIONEERING. All rights reserved.
//

import UIKit

let xScale = 300.0
let yScale = 125.0
let nodeSize = 14.0

class MapViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var processFeedbackLabel: UILabel!

    var session: Session!
    var mapSize = CGSize(width: 0, height: 0)
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        scrollView.delegate = self
        
        let activeMap = QRMap(withMapID: 0, forSession: session)
        print("Active Map: \(activeMap)")
        
        // Get safe-area size for map drawing
        var saFrame : CGRect = CGRect()
        if #available(iOS 11.0, *) {
            saFrame = self.view.safeAreaLayoutGuide.layoutFrame
        }
        else{
            saFrame = UIScreen.main.bounds
        }
        
        
        if let cartographer = QRCartographer(map: activeMap){
            self.mapSize = cartographer.frame.size
            drawMap(with: cartographer, safeArea: saFrame)
        }
        else{
            print("The map is invalid! (Need some debugging)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func drawMap(with cartographer: QRCartographer, safeArea: CGRect){
        
        var nodeButtons : [NodeButton] = []
        
        let mapView = UIView(frame: cartographer.frame)
//        mapView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        mapViewContainer.addSubview(mapView)
        
        // Resize the view container based on map size
        
        let mvcHeight = CGFloat(max(safeArea.height, mapSize.height))
        let mvcWidth = CGFloat(max(safeArea.width, mapSize.width))
        mapViewContainer.frame = CGRect(x:0,
                                        y:0,
                                        width: mvcWidth,
                                        height: mvcHeight)
        
        mapView.center.y = mapViewContainer.frame.size.height/2

        scrollView.contentSize = mapViewContainer.frame.size
        let vertOverhang = safeArea.height/scrollView.contentSize.height
        if vertOverhang < 1{
            scrollView.minimumZoomScale = vertOverhang
            scrollView.zoomScale = vertOverhang
            
        }
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.maximumZoomScale = 1.2
        
        for node in cartographer.displayableNodes{
            let newNodeButton = NodeButton(node)
            newNodeButton.addTarget(self, action: #selector(nodeSoftFocus), for: .touchUpInside)
            nodeButtons.append(newNodeButton)
            mapView.addSubview(newNodeButton)
        }
    }
    
    @objc func nodeSoftFocus(_ sender: NodeButton){
        print("ButtonPushed")
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 130, height: 30))
        label.center = CGPoint(x: sender.node.point.x + CGFloat(nodeSize/2),
                               y: sender.node.point.y + CGFloat(nodeSize) + 15)
        label.textAlignment = .center
        label.text = sender.node.title
        label.layer.cornerRadius = label.frame.height/2
        label.layer.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        label.alpha = 0.5
        sender.superview?.addSubview(label)
    }
}



extension MapViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.mapViewContainer
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        // This isn't getting the right size from the
        let heightAfterZoom = mapSize.height * scrollView.zoomScale
        let widthAfterZoom = mapSize.width * scrollView.zoomScale
        let sizeAfterZoom = CGSize(width: widthAfterZoom, height: heightAfterZoom)
        
        scrollView.contentSize = sizeAfterZoom

    }
}
