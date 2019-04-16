//
//  UserModel.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/12/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import Foundation
import Unbox

public struct UserModel {
    let rut: String
    let name: String
    let phoneNumber: String
    let email: String
    let companyName: String
    let planName: String
    let bankName: String
    let bankAccount: String
    let beneficiaries: [BeneficiaryModel]
}

extension UserModel: Unboxable {
    public init(unboxer: Unboxer) throws {
        rut = try unboxer.unbox(key: "rut")
        name = try unboxer.unbox(key: "nombre")
        phoneNumber = try unboxer.unbox(key: "telefono")
        email = try unboxer.unbox(key: "email")
        companyName = try unboxer.unbox(key: "empresa")
        planName = try unboxer.unbox(key: "plan")
        bankName = try unboxer.unbox(key: "banco")
        bankAccount = try unboxer.unbox(key: "nro_cuenta")
        beneficiaries = try unboxer.unbox(key: "beneficiarios")
    }
}
