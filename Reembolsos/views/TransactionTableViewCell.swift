//
//  TransactionTableViewCell.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/20/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    @IBOutlet var statusIndicator: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!

    var showsStatusIndicator = false {
        didSet {
            statusIndicator.isHidden = !showsStatusIndicator
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        showsStatusIndicator = false
        statusIndicator.layer.cornerRadius = statusIndicator.bounds.size.height / 2
        statusIndicator.layer.borderColor = UIColor(hex: "#999999").withAlphaComponent(0.2).cgColor
        statusIndicator.layer.borderWidth = 1
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        showsStatusIndicator = false
    }
}
