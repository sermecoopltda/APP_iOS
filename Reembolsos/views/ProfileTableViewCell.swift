//
//  ProfileTableViewCell.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/24/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = nil
        detailLabel.text = nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        detailLabel.text = nil
        accessoryType = .none
    }
}
