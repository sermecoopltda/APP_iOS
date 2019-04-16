//
//  RefundTextTableViewCell.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/19/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

class RefundTextTableViewCell: UITableViewCell {
    @IBOutlet var containerView: UIView!

    var textView: UITextView? {
        didSet {
            oldValue?.removeFromSuperview()
            guard let textView = textView else {
                return
            }
            textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            textView.frame = containerView.bounds
            containerView.addSubview(textView)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textView = nil 
    }
}
