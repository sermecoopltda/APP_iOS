//
//  TransactionDocumentModel.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/24/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import Foundation
import Unbox

public struct TransactionDocumentModel {
    let name: String
    let url: URL
}

extension TransactionDocumentModel: Unboxable {
    public init(unboxer: Unboxer) throws {
        name = try unboxer.unbox(key: "nombre")
        url = try unboxer.unbox(key: "url")
    }
}
