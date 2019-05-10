//
//  UIFont.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 5/9/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

public extension UIFont {
    static func appFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "CenturyGothic", size: size)!
    }

    static func boldAppFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "CenturyGothic-Bold", size: size)!
    }

    static func italicAppFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "CenturyGothic-Italic", size: size)!
    }

    static func boldItalicAppFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "CenturyGothic-BoldItalic", size: size)!
    }
}
