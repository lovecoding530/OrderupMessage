//
//  User.swift
//  OrderupMessage
//
//  Created by Kangtle on 10/26/17.
//  Copyright © 2017 Kangtle. All rights reserved.
//

import UIKit
import Firebase

class User: Any {
    var userId: String? = nil
    let userName: String!
    let userPassword: String!
    let color: UIColor!
    var message: String? = nil //for Waiter.
    var isEnabled: Bool = true

    static var dbRef: DatabaseReference!
    
    init(userName: String, userPassword: String, color: UIColor, message: String? = nil) {
        self.userName = userName
        self.userPassword = userPassword
        self.color = color
        self.message = message
    }
    
    init(withDic: [String: Any], userId: String? = nil) {
        self.userName = withDic["name"] as? String ?? ""
        self.userPassword = withDic["password"] as? String ?? ""
        self.color = UIColor.init(hex: withDic["color"] as? String ?? "")
        
        if let message = withDic["message"] as? String {
            self.message = message
        }
        
        if userId != nil {
            self.userId = userId
        }
        
        self.isEnabled = withDic["is_enabled"] as? Bool ?? true
    }
    
    static func getAllUsersByCode(code:String!, callback:(([User]?)->())!) {
        dbRef = Database.database().reference()
        dbRef.child(DB_RESTAURANTS).child(code!).child("users").observe(.value, with: { (snapshot) in
            let usersDic = snapshot.value as? [String: Any] ?? [:]
            var users = [User]()
            for (key, userDic) in usersDic {
                users.append(User.init(withDic: userDic as! [String : Any], userId: key))
            }
            callback(users)
        })
    }
}
