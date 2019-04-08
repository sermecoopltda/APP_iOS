//
//  TransactionsTrackingViewController.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/19/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

class TransactionsTrackingViewController: TransactionsViewController {
    convenience init() {
        self.init(nibName: String(describing: TransactionsViewController.self), bundle: nil)
        navigationItem.title = "Seguimiento"
    }

    override var showsStatusIndicator: Bool { return true }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = [
            TransactionModel(title: "Juan Pérez", subtitle: "$25.000", date: "Hoy", statusColor: UIColor(hex: "#f3f3f3")),
            TransactionModel(title: "María González", subtitle: "$12.000", date: "Ayer", statusColor: UIColor(hex: "#ffd966")),
            TransactionModel(title: "Benjamín Pérez González", subtitle: "$32.500", date: "22 de Febrero", statusColor: UIColor(hex: "#cc0000")),
            TransactionModel(title: "Teresa Pérez González", subtitle: "$10.000", date: "16 de Enero", statusColor: UIColor(hex: "#009e10")),
            TransactionModel(title: "Juan Pérez", subtitle: "$27.000", date: "22/12/2018", statusColor: UIColor(hex: "#009e10"))
        ]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        let controller = TrackingDetailViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
}
