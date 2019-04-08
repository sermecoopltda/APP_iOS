//
//  StringProtocol.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/7/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import Foundation

extension StringProtocol where Self: RangeReplaceableCollection {
    mutating func insert(separator: Self, every n: Int) {
        for index in indices.reversed() where index != startIndex &&
            distance(from: startIndex, to: index) % n == 0 {
                insert(contentsOf: separator, at: index)
        }
    }

    func inserting(separator: Self, every n: Int) -> Self {
        var string = self
        string.insert(separator: separator, every: n)
        return string
    }
}
