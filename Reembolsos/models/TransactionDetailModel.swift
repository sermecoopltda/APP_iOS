//
//  TransactionDetailModel.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/24/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import Foundation
import Unbox

public struct TransactionDetailModel {
    let identifier: String // folio
    let beneficiary: String // beneficiario
    let amount: Int // monto
    let notes: String? // observaciones
    let documents: [TransactionDocumentModel] // documentos
    let statusText: String // desc_estado
    let status: TransactionStatus // estado
    let createdAt: Date // fecha_ingreso
    let updatedAt: Date? // fecha_actualizacion
    let benefitName: String // tipo_prestacion
}

extension TransactionDetailModel: Unboxable {
    public init(unboxer: Unboxer) throws {
        identifier = try unboxer.unbox(key: "folio")
        beneficiary = try unboxer.unbox(key: "beneficiario")
        amount = try unboxer.unbox(key: "monto")
        notes = unboxer.unbox(key: "observacion")
        documents = try unboxer.unbox(key: "documentos")
        statusText = try unboxer.unbox(key: "desc_estado")
        status = try unboxer.unbox(key: "estado")
        createdAt = try unboxer.unbox(key: "fecha_ingreso", formatter: TransactionModel.dateFormatter)
        updatedAt = unboxer.unbox(key: "fecha_actualizacion", formatter: TransactionModel.dateFormatter)
        benefitName = try unboxer.unbox(key: "tipo_prestacion")
    }
}
