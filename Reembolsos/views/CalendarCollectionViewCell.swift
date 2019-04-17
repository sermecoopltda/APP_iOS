//
//  CalendarCollectionViewCell.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/16/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {
    @IBOutlet var numberLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        numberLabel.text = nil
        numberLabel.layer.cornerRadius = numberLabel.bounds.size.width / 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        numberLabel.text = nil
        isSelectable = false
    }

    override var isSelected: Bool {
        didSet {
            numberLabel.backgroundColor = isSelected ? UIColor(hex: "#009774") : UIColor.clear
            numberLabel.layer.cornerRadius = numberLabel.bounds.size.width / 2
        }
    }

    var isSelectable: Bool = false {
        didSet {
            numberLabel.textColor = isSelectable ? UIColor.black : UIColor.lightGray
        }
    }
}
