//
//  SplashViewController.swift
//  OrderupMessage
//
//  Created by Kangtle on 12/7/17.
//  Copyright © 2017 Kangtle. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        perform(#selector(gotoMainNav), with: nil, afterDelay: 2)
        // Do any additional setup after loading the view.
    }
    
    func gotoMainNav() {
        let mainNav = STORYBOARD.instantiateViewController(withIdentifier: "MainNav")
        APP_DELEGATE.window?.rootViewController = mainNav
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
