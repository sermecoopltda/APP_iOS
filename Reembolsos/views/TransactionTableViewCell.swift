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

    override func awakeFromNib() {
        super.awakeFromNib()
        statusIndicator.layer.cornerRadius = statusIndicator.bounds.size.height / 2
        statusIndicator.layer.borderColor = UIColor(hex: "#999999").withAlphaComponent(0.2).cgColor
        statusIndicator.layer.borderWidth = 1

        titleLabel.font = UIFont.boldAppFont(ofSize: 15)
        dateLabel.font = UIFont.appFont(ofSize: 13)
        subtitleLabel.font = UIFont.appFont(ofSize: 14)
    }
}
