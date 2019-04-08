//
//  CustomTextField.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/13/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
    private struct statics {
        static let leftImageContainerWidth = CGFloat(35)
    }

    var leftImage: UIImage?

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.editingRect(forBounds: bounds)
        if leftImage == nil { return rect }
        rect.origin.x += statics.leftImageContainerWidth
        rect.size.width -= statics.leftImageContainerWidth
        return rect
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.textRect(forBounds: bounds)
        if leftImage == nil { return rect }
        rect.origin.x += statics.leftImageContainerWidth
        rect.size.width -= statics.leftImageContainerWidth
        return rect
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        for view in subviews {
            if let button = view as? UIButton {
                button.setImage(button.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
                button.tintColor = .white
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        var bottomRect = rect
        bottomRect.size.height = 1 / contentScaleFactor
        bottomRect.origin.y = rect.size.height - bottomRect.size.height
        tintColor.setFill()
        UIRectFill(bottomRect)

        guard let leftImage = leftImage else { return }
        var leftImageRect = CGRect.zero
        leftImageRect.size = leftImage.size
        leftImageRect.origin.x = (statics.leftImageContainerWidth - leftImage.size.width) / 2
        leftImageRect.origin.y = (rect.size.height - leftImage.size.height) / 2
        leftImage.draw(in: leftImageRect)
    }
}
