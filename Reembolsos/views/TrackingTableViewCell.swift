//
//  TrackingTableViewCell.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/3/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

class TrackingTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        guard let oldTitleFont = textLabel?.font, let oldDetailFont = detailTextLabel?.font else { return }
        textLabel?.font = UIFont.boldAppFont(ofSize: oldTitleFont.pointSize)
        detailTextLabel?.font = UIFont.appFont(ofSize: oldDetailFont.pointSize)
    }
}
