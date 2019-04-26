//
//  TransactionsHistoryViewController.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/20/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

class TransactionsHistoryViewController: UIViewController {
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        navigationItem.title = "Historial"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        APIClient.shared.history(month: 4, year: 2019, completionHandler: {
            (success: Bool) in
            NSLog("history(month, year) API success: \(success)")
        })
    }
}
