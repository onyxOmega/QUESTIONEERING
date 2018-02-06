//
//  DBInterface.swift
//  Main_Project
//
//  Created by William Fischer on 2/6/18.
//  Copyright © 2018 QUESTIONEERING. All rights reserved.
//

import Foundation
import Theo

class DBInterface{
    
    let client : BoltClient
    
    init(){
        client = try! BoltClient(hostname: "bolt://hobby-pgjikkipbdjdgbkejddbgnal.dbs.graphenedb.com",
                                 port: 24786,
                                 username: "xcodetest",
                                 password: "b.IgGOR4248w64.eo9XziOkR198u1D9",
                                 encrypted: true)
        
        let result = client.connectSync()
        print(result)
    }
}
