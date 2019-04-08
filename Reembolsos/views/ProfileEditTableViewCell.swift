//
//  ProfileEditTableViewCell.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/19/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

class ProfileEditTableViewCell: UITableViewCell {
    @IBOutlet var textFieldContainerView: UIView!
    @IBOutlet var titleLabel: UILabel!

    var isEditable = false {
        didSet {
            titleLabel.isEnabled = isEditable
            textField?.isEnabled = isEditable
            textField?.textColor = isEditable ? .black : .lightGray
        }
    }

    var textField: UITextField? {
        didSet {
            oldValue?.removeFromSuperview()
            guard let textField = textField else {
                return
            }
            textField.textAlignment = .right
            textFieldContainerView.addSubview(textField)
            textField.frame = textFieldContainerView.bounds
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textField = nil
        isEditable = false
        titleLabel.text = nil 
    }
}
