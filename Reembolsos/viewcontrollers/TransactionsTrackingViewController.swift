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

    fileprivate var retrievedTransactions: [TransactionModel] = []
    fileprivate var cachedResults: [String: [TransactionModel]] = [:]

    override var showsStatusIndicator: Bool { return true }

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.addTarget(self, action: #selector(TransactionsTrackingViewController.refreshControlValueChanged(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        refreshData()
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
            (success: Bool, trackingEvents: [TransactionModel]) in
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
        let transaction = dataSource[indexPath.row]
        let controller = TransactionDetailViewController()
        controller.identifier = transaction.identifier
        navigationController?.pushViewController(controller, animated: true)
    }

    override func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        let controller = CalendarViewController()
        controller.dismissHandler = {
            (trackingEvents: [TransactionModel], date: Date?) in
            self.dataSource = trackingEvents
            self.retrievedTransactions = trackingEvents
            if let date = date {
                self.date = date 
            }
        }
        let navController = NavigationController(rootViewController: controller)
        present(navController, animated: true, completion: nil)
    }

    override func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        super.searchBarTextDidEndEditing(searchBar)
        guard let searchText = searchBar.text, searchText.count > 0 else {
            dataSource = retrievedTransactions
            return
        }
        if let cachedTransactions = cachedResults[searchText.localizedLowercase] {
            dataSource = cachedTransactions
            return
        }
        APIClient.shared.tracking(identifier: searchText, completionHandler: {
            (success: Bool, transactions: [TransactionModel]) in
            if success {
                self.cachedResults[searchText.localizedLowercase] = transactions
                self.dataSource = transactions
            }
        })
    }

}
