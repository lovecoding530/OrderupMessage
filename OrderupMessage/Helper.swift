//
//  Helper.swift
//  OrderupMessage
//
//  Created by Kangtle on 10/26/17.
//  Copyright © 2017 Kangtle. All rights reserved.
//

import UIKit
import Firebase

let DB_RESTAURANTS = "restaurants"
let DB_RESTAURANTS_BY_CODE = "restaurants_by_code"

let STORYBOARD = UIStoryboard.init(name: "Main", bundle: nil)
let myUserDefaults = UserDefaults.standard

let APP_DELEGATE = UIApplication.shared.delegate as! AppDelegate

extension UIColor {
    var toHexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        r = (r > 0) ? r : 0
        g = (g > 0) ? g : 0
        b = (b > 0) ? b : 0
        a = (a > 0) ? a : 0
        return String(
            format: "%02X%02X%02X",
            Int(r * 0xff),
            Int(g * 0xff),
            Int(b * 0xff)
        )
    }
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

extension UITextField {
    
    @IBInspectable var leftPadding: CGFloat {
        get {
            if let leftView = self.leftView{
                return leftView.frame.width
            }else{
                return 0
            }
        }
        set {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: self.frame.size.height))
            self.leftView = paddingView
            self.leftViewMode = .always
        }
    }
}

class Helper: Any {
    static func getRestaurantKeyByCode(code: String!, callback: ((String?)->())!){
        let dbRef = Database.database().reference()
        dbRef.child(DB_RESTAURANTS_BY_CODE).child(code!).observeSingleEvent(of: .value, with: {snapshot in
            if let restaurantKey = snapshot.value as? String{
                callback(restaurantKey)
            }else{
                callback(nil)
            }
        })
    }
    
    static func showMessage(title:String? = nil, message: String, completion: (()->())?=nil){
        
        let _title = title == nil ? "Orderup Message" : title
        
        let alert = UIAlertController(title: _title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        {
            (result : UIAlertAction) -> Void in
            if(completion != nil){
                completion!()
            }
        }
        alert.addAction(okAction)
        APP_DELEGATE.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}
