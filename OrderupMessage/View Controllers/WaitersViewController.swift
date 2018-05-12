//
//  WaitersViewController.swift
//  OrderupMessage
//
//  Created by Kangtle on 10/27/17.
//  Copyright © 2017 Kangtle. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD

class WaitersViewController: UIViewController {

    @IBOutlet weak var waiterCollectionView: UICollectionView!
    var dbRef:DatabaseReference!
    
    var waiters = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        dbRef = Database.database().reference()
        
        let code = myUserDefaults.value(forKey: "restaurant_code") as! String
        let spinnerActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
        spinnerActivity?.labelText = "Loading..."
        ////////////////////
        
        User.getAllUsersByCode(code: code) { (users) in
            spinnerActivity?.hide(true)
            self.waiters = users ?? []
            self.waiters.remove(at: self.waiters.index(where: {$0.userName == "Kitchen"})!)
            self.waiterCollectionView.reloadData()
        }
        // Do any additional setup after loading the view.
    }

    @IBAction func onNewWaiter(_ sender: Any) {
        self.performSegue(withIdentifier: "new", sender: sender)
    }
    
    @IBAction func onDone(_ sender: Any) {
        self.tabBarController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}

extension WaitersViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.waiters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SettingWaiterCell
        let waiter = waiters[indexPath.row]
        cell.nameLabel.text = waiter.userName
//        cell.passwordLabel.text = waiter.userPassword
        cell.messageLabel.text = waiter.message
        cell.colorView.backgroundColor = waiter.color
        cell.showSwitch.isOn = waiter.isEnabled
        cell.indexPath = indexPath
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2, height: 170)
    }
    
}

extension WaitersViewController: SettingWaiterCellDelegate{
    func onChangedSwitch(indexPath: IndexPath!, isOn: Bool!) {
        print(indexPath.row)

        let spinnerActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
        spinnerActivity?.labelText = "Saving..."
        ////////////////////

        let waiter = waiters[indexPath.row]
        let code = myUserDefaults.value(forKey: "restaurant_code") as! String
        let waiterRef = self.dbRef.child(DB_RESTAURANTS).child("\(code)/users/\(waiter.userId!)/is_enabled")
        waiterRef.setValue(isOn)
        spinnerActivity?.hide(true)
    }
    
    func onClickedEdit(indexPath: IndexPath!) {
        print(indexPath.row)
        let editVC = storyboard?.instantiateViewController(withIdentifier: "EditWaiter") as! EditWaiterViewController
        editVC.editingWaiter = waiters[indexPath.row]
        self.navigationController?.pushViewController(editVC, animated: true)
    }
}
