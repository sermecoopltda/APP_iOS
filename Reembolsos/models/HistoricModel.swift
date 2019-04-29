//
//  HistoricModel.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/29/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import Foundation
import Unbox

public struct HistoricModel: DateDrivenEntryProtocol {
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.isLenient = true
        return dateFormatter
    }()

    let identifier: String
    public let createdAt: Date
    let amount: Int
    public let title: String
}

extension HistoricModel: Unboxable {
    public init(unboxer: Unboxer) throws {
        identifier = try unboxer.unbox(key: "FolioReembolso")
        createdAt = try unboxer.unbox(key: "FechaProceso", formatter: HistoricModel.dateFormatter)
        amount = try unboxer.unbox(key: "ValorTotal")
        title = try unboxer.unbox(key: "Observacion")
    }
}
