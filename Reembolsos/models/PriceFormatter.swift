//
//  PriceFormatter.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/16/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import Foundation

public struct PriceFormatter {
    private static let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        let locale = Locale(identifier: "es_CL")
        numberFormatter.locale = locale
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = ""
        numberFormatter.currencySymbol = ""
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.groupingSeparator = "."
        numberFormatter.roundingMode = .down
        return numberFormatter
    }()

    static func string(from number: Int) -> String {
        return numberFormatter.string(from: number as NSNumber)!
    }
}
