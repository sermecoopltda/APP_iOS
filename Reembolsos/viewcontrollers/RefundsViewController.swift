//
//  RefundsViewController.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/14/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

class RefundsViewController: UIViewController {
    @IBOutlet var refundButton: UIButton!

    convenience init() {
        self.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: "Mis Reembolsos", image: #imageLiteral(resourceName: "tabBar-refunds"), tag: 0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Mis Reembolsos"
        refundButton.layer.cornerRadius = refundButton.bounds.size.height / 2
        refundButton.layer.borderColor = UIColor.white.cgColor
        refundButton.layer.borderWidth = 2
        refundButton.layer.masksToBounds = true
        refundButton.titleLabel?.font = UIFont.boldAppFont(ofSize: 15)
    }

    // MARK: - Control Actions

    @IBAction func refundButtonTouched(_ sender: Any) {
        let controller = RefundTermsViewController()
        let navController = NavigationController(rootViewController: controller)
        present(navController, animated: true, completion: nil)
    }
}
