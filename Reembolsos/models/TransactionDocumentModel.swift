//
//  TransactionDocumentModel.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/24/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import Foundation
import Unbox
import QuickLook

public class TransactionDocumentModel: NSObject, Unboxable, QLPreviewItem {
    let name: String
    let url: URL

    public var previewItemURL: URL?

    public var previewItemTitle: String? {
        return name
    }

    public required init(unboxer: Unboxer) throws {
        name = try unboxer.unbox(key: "nombre")
        url = try unboxer.unbox(key: "url")
    }
}
