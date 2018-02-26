//
//  DBInterface.swift
//  Main_Project
//
//  Created by William Fischer on 2/6/18.
//  Copyright © 2018 QUESTIONEERING. All rights reserved.
//

import Foundation
import Theo
import PackStream
import Result

enum RequestResult {
    // enumeration to return database requests for various purposes
    case error(String)
    case invalid
    case valid(Dictionary<String, PackProtocol>)
}

class DBInterface{
    
    let client : BoltClient
    
    init(){
        /* Access point for initial test database
        client = try! BoltClient(hostname: "bolt://hobby-pgjikkipbdjdgbkejddbgnal.dbs.graphenedb.com",
                                 port: 24786,
                                 username: "xcodetest",
                                 password: "b.IgGOR4248w64.eo9XziOkR198u1D9",
                                 encrypted: true)
         */
        
        client = try! BoltClient(hostname: "bolt://hobby-bobjgmobpijggbkecdjnbnal.dbs.graphenedb.com",
                                 port: 24786,
                                 username: "ipadapp",
                                 password: "b.9j0gd1Y3czDb.qJeQUd6wPhdgauso",
                                 encrypted: true)
        
        
        let result = client.connectSync()
        print(result)
    }
    
    // Note: This class probably redoes too much of the work from the original Theo
    // framework, but that's ok for now, because it's really helping me learn how
    // everything works in Swift
    
    func authenticate(_ username: String,_ password: String) -> RequestResult {
        
        let properties: [String:PackProtocol] = ["username": username.lowercased().trimmingCharacters(in: .whitespaces), "password": password]
        var validate : [RequestResult] = []
        client.nodesWith(label: "User", andProperties: properties){result in
            validate = self.validateNodeResult(result, isUnique: true)
        }
        return validate[0]
        
    }
    
    
    func getMapProperties(byMapID mapID: Int) -> RequestResult{
        
        let properties: [String:PackProtocol] = ["mID": mapID]
        var validate : [RequestResult] = []
        client.nodesWith(label: "Map", andProperties: properties){result in
            validate = self.validateNodeResult(result, isUnique: true)
        }
        return validate[0]
    }
    
    
    func getMapRoot(byMapID mapID: Int) -> RequestResult {
        // mID in the Database relates to mapID here.
        // Use different names to avoid syntax issues when passing parameters
        
        let query = """
            MATCH (m:Map {mID: {mapID} })-[r:HAS_ROOT]->(rn:Node)
            RETURN rn
            """
        let params: [String:PackProtocol] = ["mapID": mapID]
        let result = client.executeCypherSync(query, params: params)
        let validate = validateQueryResult(result, isUnique: true)
        
        return validate[0]
    }
    
    
    func getChildren(byID nodeID: Int) -> [RequestResult]{
        let query = """
            MATCH (n:Node) WHERE ID(n) = {nID}
            MATCH (n)-[r:HAS_CHILD_NODE]->(m:Node)
            RETURN m
            """
        let params: [String:PackProtocol] = ["nID": nodeID]
        let result = client.executeCypherSync(query, params: params)
        let validate = validateQueryResult(result, isUnique: false)
        return validate
    }
    

    
    // This function validates and returns the results of a Cypher Query request
    func validateQueryResult(_ result: Result<QueryResult,AnyError>, isUnique: Bool)-> [RequestResult]{
        
        var validate : [RequestResult] = [.invalid]
        
        switch result{
            
        case let .failure(error):
            print(error)
            
        case let .success(response):
            if isUnique{
                if response.nodes.count == 1 {
                    validate.removeAll()
                    for (id, node) in response.nodes{
                        let ppID : PackProtocol = Int(id)
                        var propertyList : [String: PackProtocol] = node.properties
                        propertyList["id"] = ppID
                        validate.append(.valid(propertyList))
                    }
                }
            }
                
            else {
                if response.nodes.count > 0 {
                    validate.removeAll()
                    for (id, node) in response.nodes{
                        let ppID : PackProtocol = Int(id)
                        var propertyList : [String: PackProtocol] = node.properties
                        propertyList["id"] = ppID
                        validate.append(.valid(propertyList))
                    }
                }
                else {
                    validate.removeAll()
                    validate.append(.valid([:]))
                }
            }
        }
        
        return validate
    }
    
    
    
    // This function validates and returns the results of a Theo Query request
    func validateNodeResult(_ result: Result<[Node], AnyError>, isUnique: Bool) -> [RequestResult]{
        var validate : [RequestResult] = [.invalid]
        switch result{
        case let .failure(error):
            print(error)
            validate[0] = .error(error.description)
        case let .success(response):
            print(response)
            if isUnique{
                if result.value!.count == 1{
                    validate[0] = .valid(response[0].properties)
                }
                else if result.value!.count == 0{
                    validate[0] = .invalid
                }
                else{
                    validate[0] = .error("Error: nodes with matching properties are not unique.")
                }
            }
            else{
                if result.value!.count > 0{
                    validate.removeAll()
                    for node in response {
                        validate.append(.valid(node.properties))
                    }
                }
            }
        }
        return validate
    }

    

} // END OF DBINTERFACE CLASS













//  OLD CODE BLOCKS, JUST IN CASE
//
//
//func getUniqueNode(label: String, properties: Dictionary<String, PackProtocol>) -> RequestResult {
//    var validate : RequestResult = .invalid
//    client.nodesWith(label: label, andProperties: properties){result in
//        print(type(of: result))
//        switch result{
//        case let .failure(error):
//            print(error)
//            validate = .error(error.description)
//        case let .success(response):
//            print(response)
//            if result.value!.count == 1{
//                validate = .valid(response[0].properties)
//            }
//            else if result.value!.count == 0{
//                validate = .invalid
//            }
//            else{
//                validate = .error("Error: nodes with matching properties are not unique.")
//            }
//        }
//    }
//    return validate
//}
//
//
//// Get and return an array of nodes with matching properties (DEPRICATED)
//func getNodeArray(label: String, properties: Dictionary<String, PackProtocol>) -> [RequestResult]{
//    var validate : [RequestResult] = []
//    client.nodesWith(label: label, andProperties: properties){result in
//        print(type(of: result))
//        switch result{
//        case let .failure(error):
//            print(error)
//            validate.append(.error(error.description))
//        case let .success(response):
//            print(response)
//            if result.value!.count > 0{
//                for node in response {
//                    validate.append(.valid(node.properties))
//                }
//            }
//            else{
//                validate.append(.invalid)
//            }
//        }
//    }
//    return validate
//}

