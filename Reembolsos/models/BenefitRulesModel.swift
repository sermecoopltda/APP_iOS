//
//  BenefitRulesModel.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/7/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import Foundation
import Unbox

public struct BenefitRulesModel {
    let benefits: [BenefitModel]
    let termsURL: URL
    let policyParagraphs: [String]
}

extension BenefitRulesModel: Unboxable {
    public init(unboxer: Unboxer) throws {
        benefits = try unboxer.unbox(key: "prestaciones")
        termsURL = try unboxer.unbox(key: "terminos_url")
        policyParagraphs = try unboxer.unbox(key: "respolitica")
    }
}
