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
//  For Future Implementation
//    var firstName : String?
//    var lastName : String?
//    var email : String?
//    var password : String?
//    var bio : String?
    
//  Low Level
    var username: String?
}




class QRMap {
    // Builds a tree data-structure containing all the Q and R nodes in the map
    var title: String
    let id: Int
    let rootNode: QRNode
    
    init(_ mID:Int){
        title = session.db.getMapTitleByID(mID)
        id = mID
        rootNode = session.db.getRootNode(mID)
    }
    
}

class QRNode {
    var label: String
    var detail: String
    init(){
        label = ""
        detail = ""
    }
}

class SManager {
    let db = DBInterface()
    
    func loginUser(withEmail email: String, withPassword password: String) -> User{
        var user = User()
        user.username = db.authenticate(email, password)
        return user
    }
    
    func getQRMap(mID:Int)->QRMap{
        let loadMap = QRMap(mID)
        
        loadMap.title = db.getMapTitleByID(mID)
        return loadMap
    }
    

    
}
