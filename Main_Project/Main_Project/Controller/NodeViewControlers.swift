//
//  NodeViewControlers.swift
//  Main_Project
//
//  Created by William Fischer on 2/23/18.
//  Copyright © 2018 QUESTIONEERING. All rights reserved.
//

import Foundation
import UIKit

class NodeButton: UIButton {
    
    var xPos: Double
    var yPos: Double
    
    let nodeID: Int
    let nodeTitle: String
    let nodeDetail: String?
    let nodeType: NodeType
    
    required init(yCenter: Double, node: QRNode) {
        // set myValue before super.init is called
        self.xPos = Double(node.gridPosition.x + 1) * 150.0
        self.yPos = Double(node.gridPosition.y + 2) * 100.0
        
        self.nodeID = node.id
        self.nodeTitle = node.title
        self.nodeDetail = node.detail
        self.nodeType = node.type
        
        super.init(frame: CGRect(x: xPos, y:yPos, width: 30, height: 30))
        
        // set other operations after super.init, if required
        backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        layer.borderWidth = 2.5
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        layer.masksToBounds = false
        layer.cornerRadius = frame.width / 2
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 15,y: 15), radius: CGFloat(10), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        switch nodeType{
        case .rNode(_):
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = circlePath.cgPath
            shapeLayer.fillColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            shapeLayer.lineWidth = 0.0
            layer.addSublayer(shapeLayer)
        default: break
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
