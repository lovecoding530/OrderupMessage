//
//  SettingWaiterCollectionViewCell.swift
//  OrderupMessage
//
//  Created by Kangtle on 10/27/17.
//  Copyright © 2017 Kangtle. All rights reserved.
//

import UIKit

class SettingWaiterCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
//    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var showSwitch: UISwitch!
    
    var indexPath: IndexPath!
    var delegate: SettingWaiterCellDelegate!
    
    @IBAction func onEdit(_ sender: Any) {
        delegate.onClickedEdit(indexPath: indexPath)
    }
    
    @IBAction func onChangedSwitch(_ sender: Any) {
        delegate.onChangedSwitch(indexPath: indexPath, isOn: showSwitch.isOn)
    }
    
}

protocol SettingWaiterCellDelegate {
    func onClickedEdit(indexPath: IndexPath!)
    func onChangedSwitch(indexPath: IndexPath!, isOn: Bool!)
}
