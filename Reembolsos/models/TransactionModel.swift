//
//  TransactionModel.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/16/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import Foundation
import Unbox

public enum TransactionStatus: String, UnboxableEnum {
    case submitted = "1"
    case inReview = "2"
    case processing = "3"
    case accepted = "4"
    case rejected = "6"

    var title: String {
        switch self {
        case .submitted: return "Enviada"
        case .inReview: return "En Revisión"
        case .processing: return "Documentación en Proceso"
        case .accepted: return "Documento Liquidado"
        case .rejected: return "Rechazada por Contralor"
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .submitted: return UIColor(hex: "#a2a2a2")
        case .accepted: return UIColor(hex: "#00be99")
        case .rejected: return UIColor(hex: "#be4040")
        default: return UIColor(hex: "#dcb12f")
        }
    }
}

public struct TransactionModel {
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.isLenient = true
        return dateFormatter
    }()

    let identifier: String
    let createdAt: Date
    let amount: Int
    let status: TransactionStatus
    let statusText: String
    let title: String
}

extension TransactionModel: Unboxable {
    public init(unboxer: Unboxer) throws {
        identifier = try unboxer.unbox(key: "folio")
        createdAt = try unboxer.unbox(key: "fecha_ingreso", formatter: TransactionModel.dateFormatter)
        amount = try unboxer.unbox(key: "monto")
        status = try unboxer.unbox(key: "cod_estado")
        statusText = try unboxer.unbox(key: "estado")
        title = try unboxer.unbox(key: "titulo")
    }
}
