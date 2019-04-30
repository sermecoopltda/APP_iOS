//
//  HistoricDetailModel.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/29/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import Foundation
import Unbox

public struct HistoricDetailModel {
    let bonification: Int // BonificacionSermecoop

    let date: Date // FechaProceso
    let identifier: String // FolioReembolso
    let beneficiary: String // Beneficiario

    let total: Int // ValorTotal
    let healthcare: Int // SistemaSalud
    let clientCost: Int // CostoSocio

    let notes: String? // Observacion

    let transaction: String // Transaccion

    let detailURL: URL // urlDetalle
}

extension HistoricDetailModel: Unboxable {
    public init(unboxer: Unboxer) throws {
        bonification = try unboxer.unbox(key: "BonificacionSermecoop")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        date = try unboxer.unbox(key: "FechaProceso", formatter: dateFormatter)
        identifier = try unboxer.unbox(key: "FolioReembolso")
        beneficiary = try unboxer.unbox(key: "Beneficiario")
        total = try unboxer.unbox(key: "ValorTotal")
        healthcare = try unboxer.unbox(key: "SistemaSalud")
        clientCost = try unboxer.unbox(key: "CostoSocio")
        notes = unboxer.unbox(key: "Observacion")
        transaction = try unboxer.unbox(key: "Transaccion")
        detailURL = try unboxer.unbox(key: "urlDetalle")
    }
}
