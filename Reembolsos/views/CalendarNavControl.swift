//
//  CalendarNavControl.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/29/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

class CalendarNavControl: UIView {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var prevButton: UIButton!
    @IBOutlet var nextButton: UIButton!

    static func control() -> CalendarNavControl {
        let nib = UINib(nibName: String(describing: CalendarNavControl.self), bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! CalendarNavControl
    }

    var prevButtonHandler: (() -> ())?
    var nextButtonHandler: (() -> ())?

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    @IBAction func prevButtonTouched(_ sender: Any) {
        prevButtonHandler?()
    }

    @IBAction func nextButtonTouched(_ sender: Any) {
        nextButtonHandler?()
    }
}
