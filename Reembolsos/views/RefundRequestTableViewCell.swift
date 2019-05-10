//
//  RefundRequestTableViewCell.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/19/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

class RefundRequestTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var actionLabel: UILabel!

    var actionText: String? {
        didSet {
            guard let actionText = actionText else {
                actionLabel.attributedText = nil
                return 
            }
            let attributes: [NSAttributedString.Key: Any] = [.font: actionLabel.font, .foregroundColor: actionLabel.textColor, .underlineStyle: NSUnderlineStyle.single.rawValue]
            let attributedString = NSAttributedString(string: actionText, attributes: attributes)
            actionLabel.attributedText = attributedString
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont.boldAppFont(ofSize: 16)
        titleLabel.text = nil
        actionLabel.font = UIFont.appFont(ofSize: 14)
        actionText = nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        actionText = nil
        accessoryType = .none
    }
}
