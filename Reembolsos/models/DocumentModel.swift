//
//  DocumentModel.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/7/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import Foundation
import Unbox

public struct DocumentModel {
    let code: Int
    let name: String
}

extension DocumentModel: Unboxable {
    public init(unboxer: Unboxer) throws {
        code = try unboxer.unbox(key: "codigo")
        name = try unboxer.unbox(key: "nombre")
    }
}
