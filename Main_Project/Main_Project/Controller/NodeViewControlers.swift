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
    let node : QRNode
    
    required init(_ node: QRNode) {
        self.node = node
        
        //   Center the button at the node's x/y point coordinates
        let buttonframe = CGRect(x: node.point.x - CGFloat(nodeSize/2),
                            y: node.point.y - CGFloat(nodeSize/2),
                            width: CGFloat(nodeSize),
                            height: CGFloat(nodeSize))
        
        super.init(frame: buttonframe)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Draw circles for buttons.
    override func draw(_ rect: CGRect) {
        //Outer circle only if it's a qNode
        let outerCirclePath =
            UIBezierPath(arcCenter: CGPoint(x: nodeSize/2,
                                            y: nodeSize/2),
                         radius: CGFloat(nodeSize),
                         startAngle: CGFloat(0),
                         endAngle:CGFloat(Double.pi * 2),
                         clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = outerCirclePath.cgPath
        shapeLayer.strokeColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        shapeLayer.fillColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        shapeLayer.lineWidth = CGFloat(nodeSize/8)
        layer.addSublayer(shapeLayer)
        
        // Inner circle also for rNodes
        switch node.type{
        case .rNode(_):
            let circlePath =
                UIBezierPath(arcCenter: CGPoint(x: nodeSize/2,
                                                y: nodeSize/2),
                             radius: CGFloat(nodeSize/1.5),
                             startAngle: CGFloat(0),
                             endAngle:CGFloat(Double.pi * 2),
                             clockwise: true)
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = circlePath.cgPath
            shapeLayer.fillColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            shapeLayer.lineWidth = 0.0
            layer.addSublayer(shapeLayer)
        default: break
        }
    }
}


/* This class draws the lines between nodes */
//class Edge: UIView{
//
//    let originNode: QRNode
//    let terminalNode: QRNode
//
//    override init(originates: QRNode, terminates: QRNode) {
//
//        // TODO: Change coordinates to CGPoint
//        let oPoint = CGPoint(x: originates.gridPosition.x,
//                             y: originates.gridPosition.y)
//        let tPoint
//        //self.frame = CGFrame
//
//        super.init(frame: frame)
//        self.backgroundColor = UIColor(white:1, alpha:0.0)
//    }
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    override func draw(_ rect: CGRect) {
//        let aPath = UIBezierPath()
//        UIColor.red.set()
//        aPath.stroke(with: .color, alpha: 1.0)
//        aPath.move(to: CGPoint(x: 50, y:50))
//
//        aPath.addLine(to: CGPoint(x:50, y:0))
//
//        //Keep using the method addLineToPoint until you get to the one where about to close the path
//        aPath.lineWidth = 2.5
//
//        aPath.close()
//        aPath.lineWidth = 2.5
//
//        //If you want to stroke it with a red color
//        UIColor.red.set()
//        aPath.stroke()
//        //If you want to fill it as well
//        aPath.fill()
//    }
//}

