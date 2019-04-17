//
//  TransactionsTrackingViewController.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/19/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

class TransactionsTrackingViewController: TransactionsViewController {
    let refreshControl = UIRefreshControl()

    convenience init() {
        self.init(nibName: String(describing: TransactionsViewController.self), bundle: nil)
        navigationItem.title = "Seguimiento"
    }

    private var date: Date?

    override var showsStatusIndicator: Bool { return true }

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.addTarget(self, action: #selector(TransactionsTrackingViewController.refreshControlValueChanged(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        refreshData()
//        dataSource = [
//            TransactionModel(title: "Juan Pérez", subtitle: "$25.000", date: "Hoy", statusColor: UIColor(hex: "#f3f3f3")),
//            TransactionModel(title: "María González", subtitle: "$12.000", date: "Ayer", statusColor: UIColor(hex: "#ffd966")),
//            TransactionModel(title: "Benjamín Pérez González", subtitle: "$32.500", date: "22 de Febrero", statusColor: UIColor(hex: "#cc0000")),
//            TransactionModel(title: "Teresa Pérez González", subtitle: "$10.000", date: "16 de Enero", statusColor: UIColor(hex: "#009e10")),
//            TransactionModel(title: "Juan Pérez", subtitle: "$27.000", date: "22/12/2018", statusColor: UIColor(hex: "#009e10"))
//        ]
    }

    private func refreshData() {
        if date == nil {
            date = Date()
        }
        guard let date = date else { return }
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        refreshControl.beginRefreshing()
        APIClient.shared.tracking(month: month, year: year, completionHandler: {
            (success: Bool, trackingEvents: [TrackingModel]) in
            if success {
                self.dataSource = trackingEvents
            }
            self.refreshControl.endRefreshing()
        })
        
    }

    @objc func refreshControlValueChanged(_ sender: Any) {
        if refreshControl.isRefreshing {
            refreshData()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        let controller = TrackingDetailViewController()
        navigationController?.pushViewController(controller, animated: true)
    }

    override func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        let controller = CalendarViewController()
        controller.dismissHandler = {
            (trackingEvents: [TrackingModel], date: Date?) in
            self.dataSource = trackingEvents
            if let date = date {
                self.date = date 
            }
        }
        let navController = NavigationController(rootViewController: controller)
        present(navController, animated: true, completion: nil)
    }

}
