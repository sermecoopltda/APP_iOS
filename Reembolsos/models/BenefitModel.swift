//
//  BenefitModel.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/7/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import Foundation
import Unbox

public struct BenefitModel {
    let code: Int
    let name: String
    let maxAmount: Int
    let documents: [DocumentModel]
}

extension BenefitModel: Unboxable {
    public init(unboxer: Unboxer) throws {
        code = try unboxer.unbox(key: "codigo")
        name = try unboxer.unbox(key: "nombre")
        maxAmount = try unboxer.unbox(key: "monto_max")
        documents = try unboxer.unbox(key: "documentos")
    }
}
