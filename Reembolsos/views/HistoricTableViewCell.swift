//
//  HistoricTableViewCell.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/29/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

class HistoricTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont.boldAppFont(ofSize: 15)
        dateLabel.font = UIFont.appFont(ofSize: 13)
        subtitleLabel.font = UIFont.appFont(ofSize: 14)
    }
}
