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
                         radius: CGFloat(nodeSize/2),
                         startAngle: CGFloat(0),
                         endAngle:CGFloat(Double.pi * 2),
                         clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = outerCirclePath.cgPath
        shapeLayer.strokeColor = nodeColor.cgColor
        shapeLayer.fillColor = bgColor.cgColor
        shapeLayer.lineWidth = CGFloat(lineWidth)
        layer.addSublayer(shapeLayer)
        
        // Inner circle also for rNodes
        switch node.type{
        case .rNode(_):
            let circlePath =
                UIBezierPath(arcCenter: CGPoint(x: nodeSize/2,
                                                y: nodeSize/2),
                             radius: CGFloat(nodeSize/2 - 2 * lineWidth),
                             startAngle: CGFloat(0),
                             endAngle:CGFloat(Double.pi * 2),
                             clockwise: true)
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = circlePath.cgPath
            shapeLayer.fillColor = nodeColor.cgColor
            shapeLayer.lineWidth = 0.0
            layer.addSublayer(shapeLayer)
        default: break
        }
    }
}


/* This class draws the lines between nodes */
class EdgeLine: UIView{

    // an edge is between start and end nodes

    var edge: QREdge
    let top : CGFloat
    let left : CGFloat
    let height : CGFloat
    let width : CGFloat


    required init(_ edge: QREdge) {
        
        // Initialize start and end nodes
        self.edge = edge
        let sNode = edge.parent
        let eNode = edge.child
        
        // Calculate frame around both nodes
        self.top = min(sNode.point.y, eNode.point.y) - CGFloat(nodeSize/2)
        self.left = min(sNode.point.x, eNode.point.x) - CGFloat(nodeSize/2)
        self.height = abs(sNode.point.y - eNode.point.y) + CGFloat(nodeSize)
        self.width = abs(sNode.point.x - eNode.point.x) + CGFloat(nodeSize)
        let edgeFrame = CGRect(x: left, y: top, width: width, height: height)
    
        super.init(frame: edgeFrame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func draw(_ rect: CGRect) {
        
        // Calculate origin with respect to the line's rectangle.
        let top = CGFloat(nodeSize/2)
        let left = CGFloat(nodeSize/2)
        let bottom = rect.height - CGFloat(nodeSize/2)
        let right = rect.width - CGFloat(nodeSize/2)
        
        let xDiagonal = CGFloat((edge.child.point.x -
                                edge.parent.point.x) /
                                CGFloat(edge.child.gridPosition.x -
                                        edge.parent.gridPosition.x) +
                                CGFloat(nodeSize/2))
        
        // Assume it originates on the top left and terminates on the top right
        var origin = CGPoint(x: left, y: top)
        var diagonal = CGPoint(x: xDiagonal, y: bottom)
        var termination = CGPoint(x: right, y: bottom)
        
        // Change the y coordinates if the previous assumption is false
        if edge.child.point.y < edge.parent.point.y{
            origin.y = bottom
            diagonal.y = top
            termination.y = top
        }
    
        // Draw the path
        let lineLayer = CAShapeLayer()
        let path = UIBezierPath()
        path.stroke(with: .color, alpha: 1.0)
        path.move(to: origin)
        path.addLine(to: diagonal)
        path.close()
        lineLayer.path = path.cgPath
        path.move(to:diagonal)
        path.addLine(to: termination)
        path.close()
        lineLayer.path = path.cgPath
        
//
//        path.lineWidth = 2.5
//        #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1).set()
//        path.stroke()
        // Format the display
        lineLayer.lineCap = kCALineCapRound
        lineLayer.lineJoin = kCALineJoinRound
        lineLayer.strokeColor = nodeColor.cgColor
        lineLayer.lineWidth = CGFloat(lineWidth)
        layer.addSublayer(lineLayer)
        
        // Add a dot at the corner if there is one
        if edge.child.gridPosition.x - edge.parent.gridPosition.x >= 2.0
        && edge.child.gridPosition.y != edge.parent.gridPosition.y {
            let circlePath =
                UIBezierPath(arcCenter: diagonal,
                             radius: CGFloat(lineWidth*3),
                             startAngle: CGFloat(0),
                             endAngle:CGFloat(Double.pi * 2),
                             clockwise: true)
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = circlePath.cgPath
            shapeLayer.fillColor = nodeColor.cgColor
            shapeLayer.lineWidth = 0.0
            layer.addSublayer(shapeLayer)
        }

    }
}

