//
//  TransactionsTrackingViewController.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/19/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

class TransactionsTrackingViewController: UIViewController {
    private struct statics {
        static let cellIdentifier = "cellIdentifier"
    }
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var emptyStateView: UIView!
    @IBOutlet var emptyStateLabel: UILabel!
    @IBOutlet var emptyStateImageView: UIImageView!

    fileprivate var shouldBeginEditing = true

    let dateFormatter = DateFormatter()

    var dataSource: [TransactionModel] = [] {
        didSet {
            if !isViewLoaded { return }
            tableView.reloadData()
            tableView.backgroundView = dataSource.count == 0 ? emptyStateView : nil
        }
    }

    let refreshControl = UIRefreshControl()

    private var date: Date?

    fileprivate var retrievedTransactions: [TransactionModel] = []
    fileprivate var cachedResults: [String: [TransactionModel]] = [:]

    convenience init() {
        self.init(nibName: nil, bundle: nil)
        dateFormatter.setLocalizedDateFormatFromTemplate("dMMMHm")
        navigationItem.title = "Seguimiento"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.setImage(#imageLiteral(resourceName: "search-icon-calendar"), for: .bookmark, state: .normal)
        searchBar.setImage(#imageLiteral(resourceName: "search-icon-calendar"), for: .bookmark, state: [.highlighted, .selected])
        searchBar.showsBookmarkButton = true
        tableView.register(UINib(nibName: String(describing: TransactionTableViewCell.self), bundle: nil), forCellReuseIdentifier: statics.cellIdentifier)
        tableView.tableFooterView = UIView(frame: .zero)
        emptyStateImageView.tintColor = .lightGray

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
}

// MARK: - <UITableViewDataSource> Methods

extension TransactionsTrackingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: statics.cellIdentifier, for: indexPath) as! TransactionTableViewCell
        let transaction = dataSource[indexPath.row]
        cell.titleLabel.text = transaction.title
        cell.subtitleLabel.text = "$\(PriceFormatter.string(from: transaction.amount))"
        cell.dateLabel.text = dateFormatter.string(from: transaction.createdAt)
        cell.statusIndicator.backgroundColor = transaction.status.backgroundColor
        return cell
    }
}

// MARK: - <UITableViewDelegate> Methods

extension TransactionsTrackingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let transaction = dataSource[indexPath.row]
        let controller = TransactionDetailViewController()
        controller.identifier = transaction.identifier
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - <UISearchBarDelegate> Methods

extension TransactionsTrackingViewController: UISearchBarDelegate {
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        let controller = CalendarViewController(mode: .tracking)
        controller.date = date
        controller.dismissHandler = {
            (trackingEvents: [DateDrivenEntryProtocol], date: Date?) in
            self.dataSource = trackingEvents as? [TransactionModel] ?? []
            self.retrievedTransactions = trackingEvents as? [TransactionModel] ?? []
            if let date = date {
                self.date = date
            }
        }
        let navController = NavigationController(rootViewController: controller)
        present(navController, animated: true, completion: nil)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
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

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchBar.isFirstResponder {
            shouldBeginEditing = false
            // refresh the search results
        }
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        let boolToReturn = shouldBeginEditing
        shouldBeginEditing = true
        return boolToReturn
    }
}
