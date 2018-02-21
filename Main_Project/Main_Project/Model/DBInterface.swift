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
    
    
    func authenticate(_ username: String,_ password: String) -> String{
        var uName = ""
        let properties: [String:PackProtocol] = ["username": username.lowercased().trimmingCharacters(in: .whitespaces), "password": password]
        client.nodesWith(label: "User", andProperties: properties){result in
            switch result{
            case let .failure(error):
                print(error)
                uName = ""
            case let .success(response):
                print(response)
                if result.value!.count > 0{
                    uName = response[0].properties["username"] as! String
                }
                else{
                    uName = ""
                }
            }
            print("Found \(result.value?.count ?? 0) nodes")
        }
        
        return uName
    }
    
    
    
    func getMapTitleByID(_ mID: Int)->String{
        var title = ""
        let properties: [String:PackProtocol] = ["mID": mID]
        client.nodesWith(label: "Map", andProperties: properties){result in
            switch result{
            case let .failure(error):
                print(error)
            case let .success(response):
                print(response)
                if result.value!.count > 0{
                    title = response[0].properties["name"] as! String
                }
                else{
                    title = ""
                }
            }
            print("Found \(result.value?.count ?? 0) nodes")
        }
        
        return title
    }
    
    
    func getRootNode(mID:Int){
        
    }
}
