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
            guard let textField = textField, let oldFont = textField.font else {
                return
            }
            textField.textAlignment = .right
            textFieldContainerView.addSubview(textField)
            textField.frame = textFieldContainerView.bounds
            textField.font = UIFont.appFont(ofSize: oldFont.pointSize)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont.boldAppFont(ofSize: 16)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textField = nil
        isEditable = false
        titleLabel.text = nil 
    }
}
