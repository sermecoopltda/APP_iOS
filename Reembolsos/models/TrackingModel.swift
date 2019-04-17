//
//  TrackingModel.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/16/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import Foundation
import Unbox

public struct TrackingModel {
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.isLenient = true
        return dateFormatter
    }()

    let identifier: String
    let createdAt: Date
    let amount: Int
    let statusCode: Int
    let statusText: String
    let title: String
}

extension TrackingModel: Unboxable {
    public init(unboxer: Unboxer) throws {
        identifier = try unboxer.unbox(key: "folio")
        createdAt = try unboxer.unbox(key: "fecha_ingreso", formatter: TrackingModel.dateFormatter)
        amount = try unboxer.unbox(key: "monto")
        statusCode = try unboxer.unbox(key: "cod_estado")
        statusText = try unboxer.unbox(key: "estado")
        title = try unboxer.unbox(key: "titulo")
    }
}
