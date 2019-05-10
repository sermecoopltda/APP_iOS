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
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var documentContainerView: UIView!
    @IBOutlet var documentImageView: UIImageView!
    @IBOutlet var documentHeightConstraint: NSLayoutConstraint!

    var showsIcon: Bool = true {
        didSet {
            iconImageView.isHidden = !showsIcon
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
        titleLabel.font = UIFont.boldAppFont(ofSize: 16)
        titleLabel.text = nil
        showsIcon = true 
        iconImageView.tintColor = UIColor(hex: "#0061ff")
        documentImage = nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        showsIcon = true
        documentImage = nil
        accessoryType = .none
    }
}
