//
//  BeneficiaryModel.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/12/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import Foundation
import Unbox

public struct BeneficiaryModel {
    let name: String
    let identifier: Int
    let rut: String
}

extension BeneficiaryModel: Unboxable {
    public init(unboxer: Unboxer) throws {
        name = try unboxer.unbox(key: "nombre")
        identifier = try unboxer.unbox(key: "id_carga")
        rut = try unboxer.unbox(key: "rut")
    }
}
