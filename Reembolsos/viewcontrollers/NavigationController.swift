//
//  NavigationController.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/14/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.barStyle = .black
        navigationBar.barTintColor = UIColor(hex: "#003ca6")
        navigationBar.tintColor = UIColor.white
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()
        navigationBar.titleTextAttributes = [.font: UIFont.boldAppFont(ofSize: 17)]
    }
}
