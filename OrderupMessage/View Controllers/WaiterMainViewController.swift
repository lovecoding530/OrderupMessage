//
//  WaiterMainViewController.swift
//  OrderupMessage
//
//  Created by Kangtle on 10/31/17.
//  Copyright © 2017 Kangtle. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD

class WaiterMainViewController: UIViewController {

    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendToField: UITextField!
    @IBOutlet weak var arrowDownLabel: UILabel!
    var dbRef:DatabaseReference!
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        dbRef = Database.database().reference()

        arrowDownLabel.text = "\u{25BC}"
        self.navigationItem.title = APP_DELEGATE.currentUser?.userName ?? ""
        messageTextView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

        getUsers()
        
        // Do any additional setup after loading the view.
    }

    func getUsers() {
        let spinnerActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
        spinnerActivity?.labelText = "Loading..."
        ////////////////////

        let code = myUserDefaults.value(forKey: "restaurant_code") as! String
        
        User.getAllUsersByCode(code: code) { (users) in
            spinnerActivity?.hide(true)

            if(users == nil) {
                return
            }
            
            self.users = users ?? []
            if let kitchenIndex = self.users.index(where: {$0.userName == "Kitchen"}) {
                let kitchen = self.users.remove(at: kitchenIndex)
                self.users.insert(kitchen, at: 0)
            }

            if let selfIndex = self.users.index(where: {$0.userId == APP_DELEGATE.currentUser?.userId ?? ""}) {
                self.users.remove(at: selfIndex)
            }

            let userNameArray = self.users.map({ (user) in
                user.userName ?? ""
            })
            
            self.sendToField.loadDropdownData(data: userNameArray)
        }
    }
    
    @IBAction func onSendMessage(_ sender: Any) {
        let code = myUserDefaults.value(forKey: "restaurant_code") as! String
        let message = messageTextView.text ?? ""
        if message.isEmpty {
            return
        }
        
        let sendUser = APP_DELEGATE.currentUser
        let receiveUser = self.users[sendToField.dropDownIndex()]
        
        let messageRef = self.dbRef.child(DB_RESTAURANTS).child(code).child("messages").child("\(receiveUser.userId ?? "")/\(sendUser?.userId ?? "")")
        
        let messageDic: [String: Any] = [
            "sender": sendUser?.userId ?? "",
            "sender_name": sendUser?.userName ?? "",
            "message": message,
            "timestamp": Int64(Date().timeIntervalSince1970),
            "state": 0
        ]
        messageRef.setValue(messageDic)
        messageTextView.text = ""
    }
    
    @IBAction func onLogout(_ sender: Any) {
        let code = myUserDefaults.value(forKey: "restaurant_code") as! String
        let usersRef = self.dbRef.child(DB_RESTAURANTS).child(code).child("users").child((APP_DELEGATE.currentUser?.userId ?? "")!)
        usersRef.child("fcm_token").setValue("none")
        
        self.navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
