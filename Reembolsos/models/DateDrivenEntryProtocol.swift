//
//  DateDrivenEntryProtocol.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/29/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import Foundation

public protocol DateDrivenEntryProtocol {
    var createdAt: Date { get }
    var title: String { get }
}
