//
//  ColorPickerController.swift
//  OrderupMessage
//
//  Created by Kangtle on 11/5/17.
//  Copyright © 2017 Kangtle. All rights reserved.
//

import UIKit
import SwiftHSVColorPicker

class ColorPickerController: UIViewController {
    
    @IBOutlet weak var colorPicker: SwiftHSVColorPicker!
    
    var doneCallback:((UIColor)->Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundColorStr = UserDefaults.standard.value(forKey: "background_color") ?? "ffffff"
        
        DispatchQueue.main.async {
            self.colorPicker.setViewColor(UIColor.init(hex: backgroundColorStr as! String))
        }
        // Do any additional setup after loading the view.
    }
    @IBAction func onDefaultColor(_ sender: Any) {
        self.colorPicker.setViewColor(UIColor.init(hex: "548ab5"))
    }
    
    @IBAction func onOk(_ sender: Any) {
        UserDefaults.standard.set(colorPicker.color.toHexString, forKey: "background_color")
        self.dismiss(animated: true, completion: nil)
        doneCallback!(colorPicker.color)
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
