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
        var name = ""
        let properties: [String:PackProtocol] = ["username": username.lowercased().trimmingCharacters(in: .whitespaces), "password": password]
        client.nodesWith(label: "User", andProperties: properties){result in
            switch result{
            case let .failure(error):
                print(error)
                name = ""
            case let .success(response):
                print(response)
                if result.value!.count > 0{
                    name = response[0].properties["username"] as! String
                }
                else{
                    name = ""
                }
            }
            print("Found \(result.value?.count ?? 0) nodes")
        }
        return name
    }
}
