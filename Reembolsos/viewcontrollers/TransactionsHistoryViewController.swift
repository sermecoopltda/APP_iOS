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
        dataSource = [
            TransactionModel(title: "Juan Pérez", subtitle: "$25.000", date: "Hoy", statusColor: nil),
            TransactionModel(title: "María González", subtitle: "$12.000", date: "Ayer", statusColor: nil),
            TransactionModel(title: "Benjamín Pérez González", subtitle: "$32.500", date: "22 de Febrero", statusColor: nil),
            TransactionModel(title: "Teresa Pérez González", subtitle: "$10.000", date: "16 de Enero", statusColor: nil),
            TransactionModel(title: "Juan Pérez", subtitle: "$27.000", date: "22/12/2018", statusColor: nil)
        ]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        let controller = HistoryDetailViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
}
