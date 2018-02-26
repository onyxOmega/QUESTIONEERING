//
//  SManager.swift
//  Main_Project
//
//  Created by William Fischer on 2/6/18.
//  Copyright © 2018 QUESTIONEERING. All rights reserved.
//

import Foundation
import PackStream


enum NodeType {
    // Enumeration for the types of nodes available
    case qNode(QNodeData), rNode(RNodeData)
}


struct QNodeData{
    var context : String?
    var dateAsked : Date?
    var synopsis : String?

    init(fromProperties properties: Dictionary<String, PackProtocol>){
        self.context = properties["context"] as? String
        self.dateAsked = properties["dateAsked"] as? Date
        self.synopsis = properties["synopsis"] as? String
    }
}


struct RNodeData{
    var url: URL?
    var notes: String?
    var dateAccessed: Date?

    init(fromProperties properties: Dictionary<String, PackProtocol>){
        self.url = properties["url"] as? URL
        self.notes = properties["dateAsked"] as? String
        self.dateAccessed = properties["synopsis"] as? Date
    }
}


struct QRNodePosition{
    /*  Structure for placing nodes in discreet grid. Actual coordinates
        will be computed by multiplying by scaling factors */
    var x: Int
    var y: Int
}


class QRNode{

    var id: Int
    var title: String
    var detail: String?
    var type: NodeType
    var map : Int
    var gridPosition = QRNodePosition(x: 0, y: 0)

    var children : [QRNode] = []
    var parent : QRNode?

    init?(fromProperties properties: Dictionary<String, PackProtocol>,
          inMap map: Int){
        self.map = map
        var typeProperties = properties
        if let id = properties["id"] as? Int{
            self.id = id
            typeProperties.removeValue(forKey: "id")
        }

        else{
            print("id fail");
            return nil
        }

        if let title = properties["title"] as? String{
            self.title = title
            typeProperties.removeValue(forKey: "title")
        }

        else{
            print("label fail"); return nil
        }

        self.detail = properties["detail"] as? String
        typeProperties.removeValue(forKey: "detail")

        // Check and see if there's context or a UUID to determine type
        if properties["context"] != nil{
            self.type = .qNode(QNodeData(fromProperties: typeProperties))
        }
        else{
            self.type = .rNode(RNodeData(fromProperties: typeProperties))
        }
    }
}

extension QRNode: CustomStringConvertible {

    var description: String {

        var text = "\(title)"


        if !children.isEmpty {
            text += " {" + children.map { $0.description }.joined(separator: ", ") + "} "
        }
        return text
    }
}


class QRMap {
    /*  Builds a tree data-structure containing all the Q and R nodes in the map
        A QRMap has a title, a description, an ID, and a node tree
        It uses the global "session" to talk to the database, which is only
        necessary durring initialization */


    var title: String?
    let id: Int
    let session: Session

    var tree: QRNode?

    /*  The initializer only does enough work to display map information on the
        map list. Loading actual map nodes comes later, when the map is selected. */
    init(withMapID mID:Int, forSession session: Session){
        self.id = mID
        self.session = session
        let mapProperties = session.db.getMapProperties(byMapID: self.id)
        switch mapProperties {
        case let .error(error):
            print(error)
        case .invalid:
            print("Invalid Response")
        case let .valid(properties):
            print(properties)
            if let title = properties["title"] as? String{
                self.title = title
            }
            self.getRoot()
        }
        print(mapProperties)
    }



    /*  This function gets the root node, which gets all it's children recursively */
    func getRoot(){
        let root = session.db.getMapRoot(byMapID: self.id)

        if let node = validateResult(root){
            node.children = getChildren(of: node)
            self.tree = node
            QRCartographer.setNodePositions(map: self)
        }
    }


    /*  This function recursively gets all descendent nodes from a starting node */
    func getChildren(of parentNode: QRNode) -> [QRNode]{
        let results = session.db.getChildren(byID: parentNode.id)
        var children : [QRNode] = []
        for result in results{
            if let node = validateResult(result){
                node.children = getChildren(of: node)
                node.parent = parentNode
                children.append(node)
            }
        }
        return children
    }

    func validateResult(_ result: RequestResult) -> QRNode?{
        var node: QRNode?

        switch result {
        case let .error(error):
            print(error)
        case .invalid:
            print("Invalid Response")
        case let .valid(properties):
            if properties.count > 0{
                node = QRNode(fromProperties: properties, inMap: self.id)
            }
        }
        return node
    }
}

// TODO: Need to calculate node positions from map

enum MatrixContents{
    case line
    case space
    case node(QRNode)
}

class QRCartographer{
    /*  The cartographer makes the maps. Or at least lays them out, calculates
        coordinates, etc. I don't think it will need instance variables. To
        start, I'm just going to set it up to figure things out from a map
        data-structure*/

    class func setNodePositions(map: QRMap){
        let xPositions = horizontalSort(map.tree!)
        print(xPositions)
    }

    class func horizontalSort(_ rootNode: QRNode) -> Int{
        // initialize the array with the tree node in the 0 spot
        var nodeColumns = [[rootNode]]

        let nodeArray = getDisplayableNodeArray(rootNode)

        /*  cartographersMatrix[m][n], where m is the height, or the number of
            rows, and is equal to twice the number of nodes to display. This
            gives space for every node to have a row plus a spacing row. 'n' is
            the number of columns, equal to the total number of nodes */
        var cartographersMatrix : [[MatrixContents]] = Array(repeating:
            Array(repeating:MatrixContents.space, count: nodeArray.count),
            count: nodeArray.count*2)

        var rNodeArray : [QRNode] = []
        var qNodeArray : [QRNode] = []
        for node in nodeArray{
            switch node.type{
            case .qNode(_):
                qNodeArray.append(node)
            case .rNode(_):
                rNodeArray.append(node)
                print(node.title)
            }
        }

        rNodeArray = rNodeArray.sorted(by: { $0.id < $1.id })
        rNodeArray.insert(rootNode, at: 0)
        /*insert code*/

        for i in 1...rNodeArray.count - 1{

            /*  find questions that are cousins, add them to a node column, then
                append the column to the nodecolumn array*/
            var thisColumn = [rNodeArray[i]]
            
            
            for node in nodeColumns[nodeColumns.endIndex - 1]{
                for cousin in node.children{
                    switch cousin.type{
                    case .qNode(_):
                        thisColumn.append(cousin)
                    case .rNode(_): break
                    }
                }
            }

            /*  See if there's
            if rNodeArray[i+1].parent!.parent!.id == rNodeArray[i].id{

            }*/



        }

//        var treeLevels = [[tree.id]]
//        // Next, get the array for the 2nd spot. Since there's only 1 child,
//
//        for child in tree.children {
//            // get all children
//            // add all qNodes and the rNode with the lowest id # (oldest rNode)
//            // sort list by id
//            var column : [Int] = []
//            var rNodes : [Int] = []
//            switch child.type{
//            case .qNode(_):
//                column.append(child.id)
//            case .rNode(_):
//                rNodes.append(child.id)
//            }
//            rNodes.sort()
//            column.append(rNodes[0])
//            column.
//        }

        return 1
    }

    // Recursive function that gets all the displayable children and populates
    // a single array
    class func getDisplayableNodeArray(_ node: QRNode) -> [QRNode]{
        var descendants : [QRNode] = []
        switch node.type{
        case .qNode(_):
            // This prevents a terminal question node from being put on the list
            if node.children.count > 0{
                descendants.append(node)
            }
        case .rNode(_):
            descendants.append(node)
        }
        for child in node.children{
            descendants.append(contentsOf: getDisplayableNodeArray(child))
        }
        return descendants
    }
}

// MARK: Session Management Structures and Classes


enum LoginStatus{
    case loggedOut
    case loggedInAs(User)
}

struct User {
    var username: String
    var uid: Int
}

class Session {
    // This is the class between the objects and the database. This class
    //basically constructs the objects from the relevant data pulled from the DB.
    //Alternatively, the objects could construct themselves by talking to the db.

    let db = DBInterface()
    let cartographer = QRCartographer()
    var loginStatus: LoginStatus = .loggedOut

    func loginUser(withUsername uName: String, withPassword uPass: String)
                                                                -> LoginStatus{
        let result = self.db.authenticate(uName, uPass)

        switch result{
        case .error(let error):
            print(error)
        case .invalid:
            print("invalid login")
        case .valid(let params):
            print("valid login")
            if let uidPP = params["uid"] {
                if let username = params["username"] as? String, let uidInt = Int(uidPP){
                    let user = User(username: username, uid: uidInt)
                    self.loginStatus = .loggedInAs(user)
                }
            }
        }
        return self.loginStatus
    }
}
















    //  ORIGINALLY IN SESSION CLASS
    //    func getQRMap(mID:Int)->QRMap{
    //        // First build a map struct, or all the data required
    //
    //        let title = db.getMapTitle(byMapID: mID)
    //        let loadMap = QRMap(withMapID: mID, andTitle: title)
    //        return loadMap
    //    }

    //    func getMapRootNode(_ mID: Int) -> QRNode{
    //        var nID: Int = db.getMapRootNode(byMapID: mID)
    //        var rootNode: QRNode(nID)
    //        return rootNode
    //    }
    //
    //    func getChildren (_ nID: Int) -> [QRNode]{
    //        var children : [QRNode]
    //        return children
    //    }


//
//
//struct QNodeStruct {
//    // Data structure to contain "contents" of a QNode
//    var id: Int
//    var title: String
//    var context: String
//    init?(_ params: Dictionary<String, PackProtocol>){
//        // Check unpacking
//        guard let id = params["id"] as? Int else{ print("id fail"); return nil}
//        guard let title = params["title"] as? String else{ print("label fail"); return nil}
//        guard let context = params["context"] as? String else{ print("context fail"); return nil}
//
//        self.id = id
//        self.title = title
//        self.context = context
//    }
//}
//
//struct RNodeStruct {
//    // Data structure to contain "contents" of an RNode
//    var id: Int
//    var title: String
//    var detail: String
//    var url: URL
//    var notes: String
//
//    init?(_ params: Dictionary<String, PackProtocol>){
//        guard let id = params["id"] as? Int,
//            let title = params["title"] as? String,
//            let detail = params["detail"] as? String,
//            let url = params["url"] as? URL,
//            let notes = params["notes"] as? String
//            else{
//                return nil
//        }
//
//        self.id = id
//        self.title = title
//        self.detail = detail
//        self.url = url
//        self.notes = notes
//    }
//}
//
//
//
//enum NodePackage {
//    // Enumeration for the types of nodes available
//    case qNode(QNodeStruct), rNode(RNodeStruct)
//}
//
//
//
//
//
//class QRNode2 {
//    // A QRNode is the building block for the tree structure of the map.
//    // A QR Node has a type (enum) and an associated data structure,
//    // as well as an array of child QRNodes. This function uses 'session'
//    // to build itself using recursive database calls.
//
//    var children : [QRNode] = []
//    var parent : QRNode?
//    var package : NodePackage
//    var id: Int
//
//    init(nodePackage: NodePackage){
//        self.package = nodePackage
//        switch self.package{
//        case let .qNode(data):
//            self.id = data.id
//        case let .rNode(data):
//            self.id = data.id
//        }
//    }
//    //
//    //    convenience init(_ NodePackage: NodePackage, parent: QRNode) {
//    //        self.parent = parent
//    //        self.init(NodePackage: NodePackage)
//    //    }
//    //
//    //    func fetchChildren() -> [QRNode]{
//    //        // Request from Database
//    //
//    //        // loop through results & build structures
//    //        // initialize for each child
//    //
//    //        children.append(<#T##newElement: QRNode##QRNode#>)
//    //
//    //    }
//
//}
