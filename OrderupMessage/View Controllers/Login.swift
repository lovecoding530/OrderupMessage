//
//  ViewController.swift
//  OrderupMessage
//
//  Created by Kangtle on 10/24/17.
//  Copyright © 2017 Kangtle. All rights reserved.
//

import UIKit
import MBProgressHUD
import Firebase

class Login: UIViewController {
    @IBOutlet weak var restaurantCodeEdit: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usersCollectionView: UICollectionView!
    
    var dbRef:DatabaseReference!

    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dbRef = Database.database().reference()
        
        let code = myUserDefaults.value(forKey: "restaurant_code") as? String ?? ""
        let password = myUserDefaults.value(forKey: "restaurant_password") as? String ?? ""

        restaurantCodeEdit.text = code
        passwordField.text = password
    }

    //MARK: IBActions
    @IBAction func onOkay(_ sender: Any) {
        let code = restaurantCodeEdit?.text ?? ""
        let password = passwordField.text ?? ""
        
        if(code.isEmpty || password.isEmpty){
            return
        }
        
        let spinnerActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
        spinnerActivity?.labelText = "Loading..."
        ////////////////////
        
        dbRef.child(DB_RESTAURANTS).child(code).child("password").observeSingleEvent(of: .value, with: {(snapshot) in
            if let savedPassword = snapshot.value as? String, savedPassword == password {
                User.getAllUsersByCode(code: code) { (users) in
                    spinnerActivity?.hide(true)
                    if(users == nil) {
                        return
                    }
                    myUserDefaults.setValue(code, forKey: "restaurant_code")
                    myUserDefaults.setValue(password, forKey: "restaurant_password")
                    self.users = users ?? []
                    if let kitchenIndex = self.users.index(where: {$0.userName == "Kitchen"}) {
                        let kitchen = self.users.remove(at: kitchenIndex)
                        self.users.insert(kitchen, at: 0)
                    }
                    self.usersCollectionView.reloadData()
                }
            }else{
                spinnerActivity?.hide(true)
                Helper.showMessage(message: "Invalid code or password")
            }
        })
    }
    
    @IBAction func onNew(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "New Restaurant", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Enter at least 5 digit number"
            textField.keyboardType = .numberPad
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Enter password"
            textField.keyboardType = .default
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            
            let codeTextField = alert?.textFields![0] // Force unwrapping because we know it exists.
            let passwordTextField = alert?.textFields![1] // Force unwrapping because we know it exists.
            let code = codeTextField?.text
            let password = passwordTextField?.text

            let restaurantsRef = self.dbRef.child(DB_RESTAURANTS).child(code ?? "")
            restaurantsRef.child("password").setValue(password ?? "")

            let newKitchen: [String: Any] = [
                "name": "Kitchen",
                "password": "Kitchen",
                "color": "ffffff",
                "is_enabled": true
            ]
            
            restaurantsRef.child("users").childByAutoId().setValue(newKitchen)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
}

extension Login: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! UsersCell
        cell.userNameLabel.text = self.users[indexPath.row].userName
        cell.userNameLabel.backgroundColor = self.users[indexPath.row].color
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        let user = self.users[indexPath.row]

        if user.userName == "Kitchen" {
            if user.userPassword != "Kitchen"{
                let alert = UIAlertController(title: nil, message: "Enter Password", preferredStyle: .alert)
                
                //2. Add the text field. You can configure it however you need.
                alert.addTextField { (textField) in
                    textField.placeholder = "Enter password"
                    textField.isSecureTextEntry = true
                }
                
                // 3. Grab the value from the text field, and print it when the user clicks OK.
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                    let passwordField = alert?.textFields![0] // Force unwrapping because we know it exists.
                    let password = passwordField?.text ?? ""
                    if password == user.userPassword{
                        self.gotoKitchen(user: user)
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

                // 4. Present the alert.
                self.present(alert, animated: true, completion: nil)
            }else{
                gotoKitchen(user: user)
            }
        }else{
            gotoWaiter(user: user)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2, height: 70)
    }
    
    func gotoKitchen(user: User){
        let mainNav = STORYBOARD.instantiateViewController(withIdentifier: "MainVC")
        self.navigationController?.pushViewController(mainNav, animated: true)
        saveUserState(user: user)
    }
    
    func gotoWaiter(user: User){
        let mainNav = STORYBOARD.instantiateViewController(withIdentifier: "WaiterMain")
        self.navigationController?.pushViewController(mainNav, animated: true)
        saveUserState(user: user)
    }
    
    func saveUserState(user: User){
        let code = myUserDefaults.value(forKey: "restaurant_code") as! String
        let fcmToken = UserDefaults.standard.value(forKey: "fcm_token")
        
        let usersRef = self.dbRef.child(DB_RESTAURANTS).child(code).child("users")
        let findRef = usersRef.queryOrdered(byChild: "fcm_token").queryEqual(toValue: fcmToken)
        findRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let usersDic = snapshot.value as? [String:Any] {
                for (key, _) in usersDic {
                    usersRef.child(key).child("fcm_token").setValue("none")
                }
            }
            usersRef.child(user.userId ?? "").child("fcm_token").setValue(fcmToken)
        })
        APP_DELEGATE.currentUser = user

    }
}
