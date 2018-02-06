//
//  SManager.swift
//  Main_Project
//
//  Created by William Fischer on 2/6/18.
//  Copyright © 2018 QUESTIONEERING. All rights reserved.
//

import Foundation
import PackStream

struct User {
    var firstName : String?
    var lastName : String?
    var email : String?
    var password : String?
    var bio : String?
}

class SManager {
    let db = DBInterface()
    
    func loginUser(withEmail email: String, withPassword password: String) -> User{
        let properties: [String:PackProtocol] = [
            "primary_email": email, "password": password]
        db.client.nodesWith(label: "User", andProperties: properties){result in
            switch result{
                case let .failure(error): print(error)
                case let .success(response): print(response)
            }
            
            
            
            print("Found \(result.value?.count ?? 0) nodes")
        }
        let user = User()
        
        return user
    }
    
}
