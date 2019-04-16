//
//  RefundDocumentTableViewCell.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/15/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

class RefundDocumentTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var actionLabel: UILabel!
    @IBOutlet var documentContainerView: UIView!
    @IBOutlet var documentImageView: UIImageView!
    @IBOutlet var documentHeightConstraint: NSLayoutConstraint!

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

    var documentImage: UIImage? {
        didSet {
            documentImageView.image = documentImage
            if documentImage == nil {
                documentHeightConstraint.constant = 10
                documentImageView.isHidden = true
            } else {
                documentHeightConstraint.constant = 170
                documentImageView.isHidden = false
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = nil
        actionText = nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        actionText = nil
        accessoryType = .none
    }
}
