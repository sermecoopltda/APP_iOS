//
//  TransactionsViewController.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/19/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

public struct TransactionModel {
    let title: String
    let subtitle: String
    let date: String
    let statusColor: UIColor?
}

class TransactionsViewController: UIViewController {
    private struct statics {
        static let cellIdentifier = "cellIdentifier"
    }
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!

    var showsStatusIndicator: Bool { return false }

    var dataSource: [TransactionModel] = [] {
        didSet {
            if !isViewLoaded { return }
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.setImage(#imageLiteral(resourceName: "search-icon-calendar"), for: .bookmark, state: .normal)
        searchBar.setImage(#imageLiteral(resourceName: "search-icon-calendar"), for: .bookmark, state: [.highlighted, .selected])
        searchBar.showsBookmarkButton = true
        tableView.register(UINib(nibName: String(describing: TransactionTableViewCell.self), bundle: nil), forCellReuseIdentifier: statics.cellIdentifier)
        tableView.tableFooterView = UIView(frame: .zero)
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
        cell.transaction = dataSource[indexPath.row]
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
        searchBar.resignFirstResponder()
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)

    }
}
