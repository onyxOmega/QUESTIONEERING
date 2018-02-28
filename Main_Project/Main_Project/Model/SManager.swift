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
    var x: Double
    var y: Double
}


class QRNode{

    var id: Int
    var title: String
    var detail: String?
    var type: NodeType
    var map : Int
    var vRank: Int
    var gridPosition = QRNodePosition(x: 0.0, y: 1.0)

    var children : [QRNode] = []
    var parent : QRNode?

    init?(fromProperties properties: Dictionary<String, PackProtocol>,
          inMap map: Int){

        self.map = map
        // TODO: Test Deletion of type-properties
//        var typeProperties = properties
        if let id = properties["id"] as? Int{
            self.id = id
//            typeProperties.removeValue(forKey: "id")
        }
        else{
            print("id fail");
            return nil
        }

        if let title = properties["title"] as? String{
            self.title = title
//            typeProperties.removeValue(forKey: "title")
        }
        else{
            print("label fail"); return nil
        }

        if let vRank = properties["vRank"] as? Int{
            self.vRank = vRank
//            typeProperties.removeValue(forKey: "vRank")
        }
        else{
            self.vRank = self.id
        }
        self.detail = properties["detail"] as? String
//        typeProperties.removeValue(forKey: "detail")

        // Check and see if there's context or a UUID to determine type
        if properties["context"] != nil{
            self.type = .qNode(QNodeData(fromProperties: properties))
        }
        else{
            self.type = .rNode(RNodeData(fromProperties: properties))
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

enum MatrixContents{
    case line
    case space
    case buffer(QRNode)
    case node(QRNode)
}

struct QREdge{
    let parent: QRNode
    let child: QRNode
    let start: Double
    let end: Double
    var vPosition : Double

    init(parent: QRNode, child: QRNode){
        self.parent = parent
        self.child = child
        start = parent.gridPosition.x
        end = child.gridPosition.x
        vPosition = 0.0
    }
}


/*  The cartographer determines the coordinates for each node on the map
    and sends them to the nodes*/
class QRCartographer{

    let map: QRMap
    let rootNode: QRNode
    var displayableNodes: [QRNode] = []

    init?(map : QRMap){
        self.map = map
        if map.tree != nil{
            self.rootNode = map.tree!
        }
        else{
            return nil
        }

        displayableNodes = getDisplayableNodeArray(from: rootNode)

        horizontalLayout()
        let edges = verticalSort(node: rootNode)
        verticalLayout(with: edges)
        print(edges)
    }

    /*  This function determines the horizontal layout of each node, given
        a list of displayable nodes and their respective logical positions
        in the tree */

    func horizontalLayout(){

        /*  initialize the array with the tree node in the 0 spot
            Node Columns is a matrix that represents what nodes belong
            at each horizontal "coordinate" based on the current visual style
            Note this doesn't have traditional matrix notation.
            It's nodeColumns[column][row]
            eg. nodeColumns[column(i.e. x-coordinate)][nodes-in-column (i.e.
            nodes with that x-coordinate)]*/

        var nodeColumns = [[rootNode]]

        var rNodeArray : [QRNode] = []
        var qNodeArray : [QRNode] = []
        for node in displayableNodes{
            switch node.type{
            case .qNode(_):
                qNodeArray.append(node)
            case .rNode(_):
                rNodeArray.append(node)
            }
        }

        // Put nodes in chronological order. Initially using id.
        // TODO: use timestamp to horizontal sort
        rNodeArray = rNodeArray.sorted(by: { $0.id < $1.id })
        //rNodeArray.insert(rootNode, at: 0)

        for i in 0...rNodeArray.count - 1{
            /*  newColumn will be built then appended to the columns. First we
                add the current reference (rNode)*/

            var thisColumn = [rNodeArray[i]]

            /*  Next we add the children of all the nodes in the previous column
                that are question nodes and add them to the current column */
            for node in nodeColumns[nodeColumns.endIndex - 1]{
                for cousin in node.children{
                    switch cousin.type{
                    case .qNode(_):
                        if nodeIsDisplayable(cousin){
                            thisColumn.append(cousin)
                        }
                    default: break
                    }
                }
            }

            // These get added as a column before a "next-column" check
            nodeColumns.append(thisColumn)

            /*  Next we check the relationship between sequential nodes.
                If two consecutive reference nodes have a grandparent
                relationship, then we add the intermediate question to the
                column */
            if i < rNodeArray.count - 1{
                // Find a qNode between two rNodes and add it
                if rNodeArray[i+1].parent?.parent?.id == rNodeArray[i].id{
                    var nextColumn :[QRNode] = [rNodeArray[i+1].parent!]
                    /*  Find cousins of the qNode and add them (note, not
                        1st cousins, necessarily. It's looking for qNode children
                        of all nodes on the previous level */
                    for node in nodeColumns[nodeColumns.endIndex - 1]{
                        for cousin in node.children{
                            switch cousin.type{
                            case .qNode(_):
                                if nodeIsDisplayable(cousin){
                                    nextColumn.append(cousin)
                                }
                            default: break
                            }
                        }
                    }
                    // And now we add these intermediates to the column array

                    nodeColumns.append(nextColumn)
                }
            }

            // Finally, we add the column to the column matrix
        }

        /*  Now, the x position for each node is set as the column index the node
            is in */
        for i in 0...nodeColumns.count - 1{
            for node in nodeColumns[i]{
                node.gridPosition.x = Double(i)
            }
        }
    }

    /*  This function uses the vSort priority and the tree structure to put
        adjacent node pairs (i.e. nodes and their connecting edge) into a
        vertical hierarchy, then assigns each node a y-coordinate for their
        grid position based on where they are in the hierarchy*/
    func verticalSort(node: QRNode) -> [QREdge]{
        var edges : [QREdge] = []
        for child in node.children.sorted(by: { $0.vRank < $1.vRank }){
            if nodeIsDisplayable(child){
                edges.append(contentsOf: verticalSort(node: child))
                let newEdge = QREdge(parent: node, child: child)
                edges.append(newEdge)
            }
        }
        return edges
        /*
         Probably belongs in another function, again
         cartographersMatrix[m][n], where m is the height, or the number of
         rows, and is equal to twice the number of nodes to display. This
         gives space for every node to have a row plus a spacing row. 'n' is
         the number of columns, equal to the total number of nodes */
        //var cartographersMatrix : [[MatrixContents]] = [[]]
    }

    /*  This function takes the list of edges produced from vertical sort and
        calculates vertical coordinates*/
    func verticalLayout(with edges: [QREdge]){
        // First, we need to keep track of what edges have been positioned.
        // The top edge will have a value of 0.0, which is the default, so
        // it's included as a "placedEdge" from the start
        var placedEdges : [QREdge] = [edges[0]]
        var maxVCoord = 1.0

        // TODO: Change badly written loops to this awesome syntax
        for (index,edge) in edges.enumerated() where index != 0{
            let lastPlacedEdge = placedEdges[placedEdges.count-1]
//            var nextSetEdge = edge

            // See if two edges are incident to each other (same parent)
            // and space accordingly by adding a 1 pt "buffer"
            if edge.parent.id == lastPlacedEdge.parent.id{
                maxVCoord += 1.0
                edge.child.gridPosition.y = maxVCoord
//                edge.child.gridPosition.y =
//                    lastPlacedEdge.child.gridPosition.y + 1.0
                placedEdges.append(edge)
            }
            // If not, see if the next edge is the parent to a set of edges
            else if edge.child.id == lastPlacedEdge.parent.id{
                var yCoordCount = 0
                var yCoordSum = 0.0
                for childEdges in edges
                where childEdges.parent.id == edge.child.id{
                    yCoordCount += 1
                    yCoordSum += childEdges.child.gridPosition.y
                }
                edge.child.gridPosition.y = yCoordSum/Double(yCoordCount)
                placedEdges.append(edge)
            }
                // TODO: Modify this function to test for gaps and efficiently fill space (maybe)
            else{
                // get the lowest position used so far and add a buffer
                maxVCoord += 1.0
                edge.child.gridPosition.y = maxVCoord
            }
        }
        
        /*  Finally, we calculate the root node position as the average of it's
         descendant node positions */
        var yCoordCount = 0
        var yCoordSum = 0.0
        for child in rootNode.children where nodeIsDisplayable(child){
            yCoordCount += 1
            yCoordSum += child.gridPosition.y
        }
        rootNode.gridPosition.y = yCoordSum/Double(yCoordCount)
        
    }

    // This function returns true if a node is in the displayable node array
    func nodeIsDisplayable(_ node: QRNode)-> Bool{
        let isDisplayable = displayableNodes.contains{ element in
            if element.id == node.id {
                return true
            }
            else{
                return false
            }
        }
        return isDisplayable
    }

    /*  Recursive function that gets all the displayable children and populates
        a single array. The array is sorted by vRank from newest generation up
        to facilitate the vRank function (so extra recursion isn't necessary)*/
    func getDisplayableNodeArray(from node: QRNode) -> [QRNode]{
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
            descendants.append(contentsOf: getDisplayableNodeArray(from: child)
                                           .sorted(by: { $0.vRank < $1.vRank }))
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


/*  This class interfaces between the objects and the database. This class
    basically constructs the objects from the relevant data pulled from the DB.
    Alternatively, the objects could construct themselves by talking to the db.

    It may be appropriate to make this a static class instead of producing an
    instance. */
class Session {

    let db = DBInterface()
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












//  ORIGINALLY IN VERTICAL SORT FOR QRCARTOGRAPHER
//        for column in nodeColumns{
//            for parent in column{
//                var connection : [MatrixContents] = []
//                let vSortedChildren : [QRNode] =
//                    parent.children.sorted(by: { $0.vRank < $1.vRank })
//
//                for child in vSortedChildren{
//                    let childIsDisplayable = qNodeArray.contains{ element in
//                        if element.id == child.id {
//                            return true
//                        }
//                        else{
//                            return false
//                        }
//                    }
//                    if childIsDisplayable{
//                        // insert appropriate number of spaces, which is i
//                        let spaceCount = parent.gridPosition.x
//                        let lineCount = child.gridPosition.x - spaceCount - 1
//                        let spaces : [MatrixContents] =
//                            Array(repeatElement(.space, count: spaceCount))
//                        let lines : [MatrixContents] =
//                            Array(repeatElement(.line, count: lineCount))
//                        connection.append(contentsOf: spaces)
//                        connection.append(.node(parent))
//                        connection.append(contentsOf: lines)
//                        connection.append(.node(child))
//
//                    }
//                }
//            }
//        }






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
