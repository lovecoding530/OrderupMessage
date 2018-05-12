//
//  MainViewController.swift
//  OrderupMessage
//
//  Created by Kangtle on 10/29/17.
//  Copyright © 2017 Kangtle. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD

class MainViewController: UIViewController {
    @IBOutlet weak var waiterCollectionView: UICollectionView!

    var dbRef:DatabaseReference!
    
    var waiters = [User]()
    
    var sentWaiters = [String]()

    var timer: Timer? = nil
    
    var isWhite = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        
        let backgroundColorStr = UserDefaults.standard.string(forKey: "background_color") ?? "548AB5"
        self.view.backgroundColor = UIColor.init(hex: backgroundColorStr)

        dbRef = Database.database().reference()
        
        let code = myUserDefaults.value(forKey: "restaurant_code") as! String
        let spinnerActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
        spinnerActivity?.labelText = "Loading..."
        ////////////////////
        
        User.getAllUsersByCode(code: code) { (users) in
            spinnerActivity?.hide(true)
            self.waiters = users ?? []
            self.waiters.remove(at: self.waiters.index(where: {$0.userName == "Kitchen"})!)
            self.waiters = self.waiters.filter({$0.isEnabled == true})
            self.waiterCollectionView.reloadData()
        }
        
//        let messageRef = self.dbRef.child(DB_RESTAURANTS).child(code).child("messages")
//        
//        messageRef.observe(.childRemoved, with: { (snapshot) in
//            if snapshot.key != "kitchen" {
//                if self.sentWaiters.contains(snapshot.key){
//                    self.sentWaiters.remove(at: self.sentWaiters.index(of: snapshot.key)!)
//                }
//            }
//        })
    
        runTimer()
        // Do any additional setup after loading the view.
    }
    
    func runTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateState), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    func updateState(){
        isWhite = !isWhite
        self.waiterCollectionView.reloadData()
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

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.waiters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! UsersCell
        
        let waiter = waiters[indexPath.row]
        cell.userNameLabel.text = self.waiters[indexPath.row].userName
        
        if sentWaiters.contains(waiter.userId!) {
            if isWhite {
                cell.userNameLabel.backgroundColor = UIColor.white
            }else{
                cell.userNameLabel.backgroundColor = self.waiters[indexPath.row].color
            }
        }else{
            cell.userNameLabel.backgroundColor = self.waiters[indexPath.row].color
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let waiter = waiters[indexPath.row]
        if sentWaiters.contains(waiter.userId!) {
            return
        }
        
        let code = myUserDefaults.value(forKey: "restaurant_code") as! String
        let messageRef = self.dbRef.child(DB_RESTAURANTS).child(code).child("messages").child("\(waiter.userId ?? "")/kitchen")
        let messageDic: [String: Any] = [
            "sender": "kitchen",
            "sender_name": "Kitchen",
            "message": waiter.message ?? "",
            "timestamp": Int64(Date().timeIntervalSince1970),
            "state": 0
        ]
        
        messageRef.setValue(messageDic)
        
        messageRef.observeSingleEvent(of: .childRemoved, with: { (snapshot) in
            print("child changed")
            if self.sentWaiters.contains(waiter.userId ?? ""){
                self.sentWaiters.remove(at: self.sentWaiters.index(of: waiter.userId ?? "")!)
            }
        })
        
        self.sentWaiters.append(waiter.userId!)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2, height: 70)
    }

}
