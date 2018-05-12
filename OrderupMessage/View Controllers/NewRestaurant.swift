//
//  NewRestaurant.swift
//  OrderupMessage
//
//  Created by Kangtle on 11/4/17.
//  Copyright © 2017 Kangtle. All rights reserved.
//

import UIKit
import MBProgressHUD
import Firebase

class NewRestaurant: UIViewController {

    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    var dbRef:DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dbRef = Database.database().reference()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onOk(_ sender: Any) {
        let code = codeField.text ?? ""
        let password = passwordField.text ?? ""
        let confirmPassword = confirmPasswordField.text ?? ""
        if code.isEmpty || password.isEmpty || confirmPassword.isEmpty || password != confirmPassword{
            return
        }else{
            let restaurantsRef = self.dbRef.child(DB_RESTAURANTS).child(code)
            restaurantsRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    self.dismiss(animated: true, completion: {
                        Helper.showMessage(message: "The restaurant already exists")
                    })
                }else{
                    restaurantsRef.child("password").setValue(password)
                    
                    let newKitchen: [String: Any] = [
                        "name": "Kitchen",
                        "password": "Kitchen",
                        "color": "ffffff",
                        "is_enabled": true
                    ]
                    
                    restaurantsRef.child("users/kitchen").setValue(newKitchen)
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
