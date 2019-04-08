//
//  UIViewAnimationOptionsWithCurve.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/19/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

extension UIView.AnimationOptions {
    init(curve: UIView.AnimationCurve) {
        switch curve.rawValue {
        case UIView.AnimationCurve.easeInOut.rawValue: self.init(rawValue: UIView.AnimationOptions.curveEaseInOut.rawValue)
        case UIView.AnimationCurve.easeIn.rawValue: self.init(rawValue: UIView.AnimationOptions.curveEaseIn.rawValue)
        case UIView.AnimationCurve.easeOut.rawValue: self.init(rawValue: UIView.AnimationOptions.curveEaseOut.rawValue)
        default: self.init(rawValue: UIView.AnimationOptions.curveLinear.rawValue)
        }
    }
}
