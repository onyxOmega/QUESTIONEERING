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
        var user = User()
        user.firstName = db.authenticate(email, password)
        return user
    }
    
}
