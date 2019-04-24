//
//  TransactionsViewController.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/19/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

class TransactionsViewController: UIViewController {
    private struct statics {
        static let cellIdentifier = "cellIdentifier"
    }
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var emptyStateView: UIView!
    @IBOutlet var emptyStateLabel: UILabel!
    @IBOutlet var emptyStateImageView: UIImageView!

    fileprivate var shouldBeginEditing = true

    var showsStatusIndicator: Bool { return false }
    let dateFormatter = DateFormatter()

    var dataSource: [TransactionModel] = [] {
        didSet {
            if !isViewLoaded { return }
            tableView.reloadData()
            tableView.backgroundView = dataSource.count == 0 ? emptyStateView : nil
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.setLocalizedDateFormatFromTemplate("dMMMHm")
        searchBar.setImage(#imageLiteral(resourceName: "search-icon-calendar"), for: .bookmark, state: .normal)
        searchBar.setImage(#imageLiteral(resourceName: "search-icon-calendar"), for: .bookmark, state: [.highlighted, .selected])
        searchBar.showsBookmarkButton = true
        tableView.register(UINib(nibName: String(describing: TransactionTableViewCell.self), bundle: nil), forCellReuseIdentifier: statics.cellIdentifier)
        tableView.tableFooterView = UIView(frame: .zero)
        emptyStateImageView.tintColor = .lightGray
    }
}

// MARK: - <UITableViewDataSource> Methods

extension TransactionsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: statics.cellIdentifier, for: indexPath) as! TransactionTableViewCell
        cell.showsStatusIndicator = showsStatusIndicator
        let transaction = dataSource[indexPath.row]
        cell.titleLabel.text = transaction.title
        cell.subtitleLabel.text = "$\(PriceFormatter.string(from: transaction.amount))"
        cell.dateLabel.text = dateFormatter.string(from: transaction.createdAt)
        cell.statusIndicator.backgroundColor = transaction.status.backgroundColor
        return cell
    }
}

// MARK: - <UITableViewDelegate> Methods

extension TransactionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TransactionsViewController: UISearchBarDelegate {
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        NSLog("calendar")
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil 
        searchBar.resignFirstResponder()
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        NSLog("searchBarTextDidEndEditing")
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
