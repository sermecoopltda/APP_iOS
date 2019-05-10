//
//  StatusIndicatorView.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/3/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

class StatusIndicatorView: UIView {
    private struct statics {
        static let lineWidth = CGFloat(2)
        static let smallCircleDiameter = CGFloat(26)
        static let largeCircleDiameter = CGFloat(38)
    }

    public enum PossibleState {
        case started
        case intermediate
        case ended
    }

    private var titles: [StatusIndicatorView.PossibleState: String] = [:] {
        didSet {
            setNeedsDisplay()
        }
    }

    var currentState: StatusIndicatorView.PossibleState = .started {
        didSet {
            setNeedsDisplay()
        }
    }

    var currentStateColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .redraw
        isOpaque = false
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentMode = .redraw
        isOpaque = false
    }

    func setTitle(_ title: String?, for state: StatusIndicatorView.PossibleState) {
        titles[state] = title
    }

    func title(for state: StatusIndicatorView.PossibleState) -> String? {
        return titles[state]
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: statics.largeCircleDiameter + 120)
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.beginTransparencyLayer(auxiliaryInfo: nil)
        let darkColor = UIColor(hex: "#0a0a0a")
        let lightColor = UIColor(hex: "#a0a0a0")
        let segmentWidth = bounds.size.width / 6
        context.setLineWidth(statics.lineWidth)
        context.setLineCap(.round)
        let lineY = statics.largeCircleDiameter / 2
        let startPoint = CGPoint(x: segmentWidth, y: lineY)
        let intermediatePoint = CGPoint(x: segmentWidth * 3, y: lineY)
        let endPoint = CGPoint(x: segmentWidth * 5, y: lineY)
        // draw line 1/2
        context.setStrokeColor(currentState == .started ? lightColor.cgColor : darkColor.cgColor)
        context.move(to: startPoint)
        context.addLine(to: intermediatePoint)
        context.drawPath(using: .fillStroke)
        // draw line 2/2
        context.setStrokeColor(currentState == .ended ? darkColor.cgColor : lightColor.cgColor)
        context.move(to: intermediatePoint)
        context.addLine(to: endPoint)
        context.drawPath(using: .fillStroke)

        // draw circle 1/3
        let c1Diameter = currentState == .started ? statics.largeCircleDiameter : statics.smallCircleDiameter
        let c1Rect = CGRect(x: startPoint.x - c1Diameter / 2, y: lineY - c1Diameter / 2, width: c1Diameter, height: c1Diameter)
        context.setFillColor(darkColor.cgColor)
        context.fillEllipse(in: c1Rect)
        // draw circle 2/3
        let c2Diameter = currentState == .intermediate ? statics.largeCircleDiameter : statics.smallCircleDiameter
        let c2Rect = CGRect(x: intermediatePoint.x - c2Diameter / 2, y: lineY - c2Diameter / 2, width: c2Diameter, height: c2Diameter)
        context.setFillColor(currentState == .started ? lightColor.cgColor : darkColor.cgColor)
        context.fillEllipse(in: c2Rect)
        // draw circle 3/3
        let c3Diameter = currentState == .ended ? statics.largeCircleDiameter : statics.smallCircleDiameter
        let c3Rect = CGRect(x: endPoint.x - c3Diameter / 2, y: lineY - c3Diameter / 2, width: c3Diameter, height: c3Diameter)
        context.setFillColor(currentState == .ended ? darkColor.cgColor : lightColor.cgColor)
        context.fillEllipse(in: c3Rect)
        context.saveGState()
        context.setBlendMode(.sourceOut)
        context.setFillColor(UIColor.black.cgColor)
        if currentState == .started {
            context.fillEllipse(in: c1Rect.insetBy(dx: statics.lineWidth, dy: statics.lineWidth))
            context.fillEllipse(in: c2Rect.insetBy(dx: statics.lineWidth, dy: statics.lineWidth))
        } else if currentState == .intermediate {
            context.fillEllipse(in: c2Rect.insetBy(dx: statics.lineWidth, dy: statics.lineWidth))
        }
        context.fillEllipse(in: c3Rect.insetBy(dx: statics.lineWidth, dy: statics.lineWidth))
        context.restoreGState()
        if let currentStateColor = currentStateColor {
            let currentCircle = currentState == .started ? c1Rect : currentState == .intermediate ? c2Rect : c3Rect
            context.setFillColor(currentStateColor.cgColor)
            context.fillEllipse(in: currentCircle.insetBy(dx: 2*statics.lineWidth, dy: 2*statics.lineWidth))
        }
        context.endTransparencyLayer()

        // draw titles
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping

        var attributes: [NSAttributedString.Key: Any] = [.font: UIFont.appFont(ofSize: 12), .paragraphStyle: paragraphStyle]
        if let title = title(for: .started) {
            attributes[.foregroundColor] = darkColor
            let title1Rect = CGRect(x: 0, y: statics.largeCircleDiameter, width: bounds.size.width / 3, height: bounds.size.height - statics.largeCircleDiameter).insetBy(dx: 5, dy: 5)
            let attributedTitle = NSAttributedString(string: title, attributes: attributes)
            attributedTitle.draw(with: title1Rect, options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin], context: nil)
        }

        if let title = title(for: .intermediate) {
            attributes[.foregroundColor] = currentState == .started ? lightColor : darkColor
            let title2Rect = CGRect(x: bounds.size.width / 3, y: statics.largeCircleDiameter, width: bounds.size.width / 3, height: bounds.size.height - statics.largeCircleDiameter).insetBy(dx: 5, dy: 5)
            let attributedTitle = NSAttributedString(string: title, attributes: attributes)
            attributedTitle.draw(with: title2Rect, options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin], context: nil)
        }

        if let title = title(for: .ended) {
            attributes[.foregroundColor] = currentState == .ended ? darkColor : lightColor
            let title3Rect = CGRect(x: bounds.size.width / 3 * 2, y: statics.largeCircleDiameter, width: bounds.size.width / 3, height: bounds.size.height - statics.largeCircleDiameter).insetBy(dx: 5, dy: 5)
            NSLog("title3Rect: \(title3Rect)")
            let attributedTitle = NSAttributedString(string: title, attributes: attributes)
            attributedTitle.draw(with: title3Rect, options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin], context: nil)
        }
    }
}
