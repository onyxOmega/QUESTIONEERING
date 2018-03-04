//
//  MapViewController.swift
//  Main_Project
//
//  Created by William Fischer on 2/7/18.
//  Copyright © 2018 QUESTIONEERING. All rights reserved.
//

import UIKit

let xScale = 130.0
let yScale = 110.0
let nodeSize = 25.0
let lineWidth = 2.0
let nodeColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
let bgColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)

class MapViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var processFeedbackLabel: UILabel!

    var session: Session!
    var mapSize = CGSize(width: 0, height: 0)
    var safeArea : CGRect = CGRect()

    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        scrollView.delegate = self
        
        self.view.backgroundColor = bgColor
        
        let activeMap = QRMap(withMapID: 0, forSession: session)
        print("Active Map: \(activeMap)")
        
        // Get safe-area size for map drawing
        if #available(iOS 11.0, *) {
            safeArea = self.view.safeAreaLayoutGuide.layoutFrame
        }
        else{
            safeArea = UIScreen.main.bounds
        }
        
        
        if let cartographer = QRCartographer(map: activeMap){
            self.mapSize = cartographer.frame.size
            drawMap(with: cartographer)
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
    
    
    func drawMap(with cartographer: QRCartographer){
        
        var nodeButtons : [NodeButton] = []
        
        let mapView = UIView(frame: cartographer.frame)
        mapViewContainer.addSubview(mapView)
        
        // Resize the map view container based on map size. Choose the larger:
        // screen height (save area) or map size.
        let mvcHeight = CGFloat(max(safeArea.height, mapSize.height))
        let mvcWidth = CGFloat(max(safeArea.width, mapSize.width))
        mapViewContainer.frame = CGRect(x:0,
                                        y:0,
                                        width: mvcWidth,
                                        height: mvcHeight)
        
        // Center the map view vertically in it's container
        mapView.center.y = mvcHeight/2

        scrollView.contentSize = mapViewContainer.frame.size
        let vertOverhang = safeArea.height/scrollView.contentSize.height
        if vertOverhang < 1{
            scrollView.minimumZoomScale = vertOverhang
            scrollView.zoomScale = vertOverhang
        }
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.maximumZoomScale = 1.5
        
        for edge in cartographer.edges{
            let newEdge = EdgeLine(edge)
            mapView.addSubview(newEdge)
        }
        
        
        for node in cartographer.displayableNodes{
            let newNodeButton = NodeButton(node)
            newNodeButton.addTarget(self, action: #selector(presentPopup), for: .touchUpInside)
            nodeButtons.append(newNodeButton)
            mapView.addSubview(newNodeButton)
        }
    }
    
    @objc func nodeSoftFocus(_ sender: NodeButton){
        print("ButtonPushed")
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 130, height: 30))
        label.center = CGPoint(x: sender.node.point.x,
                               y: sender.node.point.y + CGFloat(nodeSize/2) + 20)
        label.textAlignment = .center
        label.text = sender.node.title
        label.layer.cornerRadius = label.frame.height/2
        label.layer.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        label.alpha = 0.5
        sender.superview?.addSubview(label)
    }
    
    @objc func presentPopup(_ sender: NodeButton){
        switch sender.node.type{
            
        case .rNode:
            let popupView = RPopupViewController(nibName: "RPopupView", bundle: nil)
            popupView.preferredContentSize = CGSize(width: 290, height: 450)
            popupView.modalPresentationStyle = UIModalPresentationStyle.popover
            popupView.node = sender.node
            present(popupView, animated: true, completion: nil)
            popupView.saveButton.addTarget(self, action: #selector(confirmModification), for: .touchUpInside)
            let qPopupViewController = popupView.popoverPresentationController
            qPopupViewController?.sourceView = sender
            
        case .qNode:
            let popupView = QPopupViewController(nibName: "QPopupView", bundle: nil)
            popupView.preferredContentSize = CGSize(width: 290, height: 450)
            popupView.modalPresentationStyle = UIModalPresentationStyle.popover
            popupView.node = sender.node
            present(popupView, animated: true, completion: nil)
            popupView.saveButton.addTarget(self, action: #selector(confirmModification), for: .touchUpInside)
            let qPopupViewController = popupView.popoverPresentationController
            qPopupViewController?.sourceView = sender
        }
    
    }
    
    @objc func confirmModification(){
        //TODO: update the model and reload UI
        print("I can not update the model from here.")
    }

}



extension MapViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.mapViewContainer
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        let heightAfterZoom = CGFloat(mapSize.height * scrollView.zoomScale)
        let widthAfterZoom = CGFloat(mapSize.width * scrollView.zoomScale)
        let sizeAfterZoom = CGSize(width: widthAfterZoom, height: heightAfterZoom)
        scrollView.contentSize = sizeAfterZoom
//        scrollView.subviews[0].subviews[0].center.y =
//            (max(mapSize.height, safeArea.height) / scrollView.zoomScale)/2
        
        scrollView.subviews[0].center.y = max(scrollView.contentSize.height/2,
                                              safeArea.height/2)
    }
}
