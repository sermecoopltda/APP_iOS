//
//  TransactionsHistoryViewController.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/20/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

class TransactionsHistoryViewController: TransactionsViewController {
    convenience init() {
        self.init(nibName: String(describing: TransactionsViewController.self), bundle: nil)
        navigationItem.title = "Historial"
    }

    override var showsStatusIndicator: Bool { return false }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        let controller = HistoryDetailViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
}
