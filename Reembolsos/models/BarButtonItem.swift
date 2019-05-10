//
//  BarButtonItem.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 5/9/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

public class BarButtonItem: UIBarButtonItem {
    static func doneButtonItem(title: String?, target: Any?, action: Selector?) -> BarButtonItem {
        let item = BarButtonItem(title: title, style: .done, target: target, action: action)
        item.setTitleTextAttributes([.font: UIFont.boldAppFont(ofSize: 15)], for: [.normal])
        item.setTitleTextAttributes([.font: UIFont.boldAppFont(ofSize: 15)], for: [.highlighted])
        item.setTitleTextAttributes([.font: UIFont.boldAppFont(ofSize: 15)], for: [.selected])
        item.setTitleTextAttributes([.font: UIFont.boldAppFont(ofSize: 15)], for: [.disabled])
        return item
    }

    static func plainButtonItem(title: String?, target: Any?, action: Selector?) -> BarButtonItem {
        let item = BarButtonItem(title: title, style: .plain, target: target, action: action)
        item.setTitleTextAttributes([.font: UIFont.appFont(ofSize: 15)], for: [.normal])
        item.setTitleTextAttributes([.font: UIFont.appFont(ofSize: 15)], for: [.highlighted])
        item.setTitleTextAttributes([.font: UIFont.appFont(ofSize: 15)], for: [.selected])
        item.setTitleTextAttributes([.font: UIFont.appFont(ofSize: 15)], for: [.disabled])
        return item
    }
}
