//
//  String.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/16/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import Foundation

public extension String {
    var localizedFirstCapitalized: String {
        let first = String(prefix(1)).localizedCapitalized
        let other = String(dropFirst())
        return first + other
    }
}
