//
//  EditWaiterViewController.swift
//  OrderupMessage
//
//  Created by Kangtle on 10/27/17.
//  Copyright © 2017 Kangtle. All rights reserved.
//

import UIKit
import SwiftHSVColorPicker
import Firebase
import MBProgressHUD

class EditWaiterViewController: UIViewController {

    @IBOutlet weak var colorPicker: SwiftHSVColorPicker!
    @IBOutlet weak var waiterNameEdit: UITextField!
//    @IBOutlet weak var waiterPasswordEdit: UITextField!
    @IBOutlet weak var messageEdit: UITextField!

    var dbRef:DatabaseReference!
    
    var editingWaiter: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dbRef = Database.database().reference()
        
        if (editingWaiter != nil) {
            waiterNameEdit.text = editingWaiter?.userName
            messageEdit.text = editingWaiter?.message
            
            DispatchQueue.main.async {
                self.colorPicker.setViewColor((self.editingWaiter?.color)!)
            }
        }else{
            DispatchQueue.main.async {
                self.colorPicker.setViewColor(UIColor.white)
            }
        }
        // Do any additional setup after loading the view.
    }

    @IBAction func onSave(_ sender: Any) {
        let name = waiterNameEdit.text ?? ""
//        let password = waiterPasswordEdit.text ?? ""
        let message = messageEdit.text ?? ""
        let colorString = colorPicker.color.toHexString
        if name.isEmpty && message.isEmpty {
            return
        }
        
        let waiterDic: [String : Any] = [
            "name": name,
            "password": "Waiter",
            "message": message,
            "color": colorString,
            "is_enabled": true
        ];

        let spinnerActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
        spinnerActivity?.labelText = "Saving..."
        ////////////////////

        let code = myUserDefaults.value(forKey: "restaurant_code") as! String
        var waiterRef = self.dbRef.child(DB_RESTAURANTS).child(code).child("users")
        if self.editingWaiter == nil {
            waiterRef = waiterRef.childByAutoId()
        }else{
            waiterRef = waiterRef.child(self.editingWaiter?.userId ?? "")
        }
        waiterRef.setValue(waiterDic)
        spinnerActivity?.hide(true)
        self.navigationController?.popViewController(animated: true)
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
