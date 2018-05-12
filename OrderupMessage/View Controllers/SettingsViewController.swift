//
//  SettingsViewController.swift
//  OrderupMessage
//
//  Created by Kangtle on 11/5/17.
//  Copyright © 2017 Kangtle. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UITableViewController {

    @IBOutlet weak var backgroundColorView: UIView!
    @IBOutlet weak var logoutTimeField: UITextField!
    @IBOutlet weak var vibrateSwitch: UISwitch!
    @IBOutlet weak var kitchenPasswordField: UITextField!
    @IBOutlet weak var restaurantCodeLabel: UILabel!
    @IBOutlet weak var restaurantPasswordField: UITextField!

    var dbRef:DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbRef = Database.database().reference()
        
        let backgroundColorStr = UserDefaults.standard.string(forKey: "background_color") ?? "ffffff"
        backgroundColorView.backgroundColor = UIColor.init(hex: backgroundColorStr)

        let code = myUserDefaults.string(forKey: "restaurant_code")  ?? ""
        let password = myUserDefaults.string(forKey: "restaurant_password") ?? ""
        restaurantCodeLabel.text = code
        restaurantPasswordField.text = password
        
        kitchenPasswordField.text = APP_DELEGATE.currentUser?.userPassword
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    @IBAction func onDone(_ sender: Any) {
        let kitchenPassword = kitchenPasswordField.text ?? ""
        let restaurantPassword = restaurantPasswordField.text ?? ""

        let code = myUserDefaults.string(forKey: "restaurant_code")

        dbRef.child(DB_RESTAURANTS).child(code!).child("password").setValue(restaurantPassword)
        dbRef.child(DB_RESTAURANTS).child(code!).child("users/kitchen/password").setValue(kitchenPassword)
        self.tabBarController?.dismiss(animated: true, completion: nil)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let colorPickerController = segue.destination as! ColorPickerController
        colorPickerController.doneCallback = { color in
            let backgroundColorStr = UserDefaults.standard.string(forKey: "background_color") ?? "ffffff"
            self.backgroundColorView.backgroundColor = UIColor.init(hex: backgroundColorStr)
        }
    }

}
