//
//  TransactionsViewController.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/19/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

//public struct TransactionModel {
//    let title: String
//    let subtitle: String
//    let date: String
//    let statusColor: UIColor?
//}

class TransactionsViewController: UIViewController {
    private struct statics {
        static let cellIdentifier = "cellIdentifier"
    }
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!

    var showsStatusIndicator: Bool { return false }
    let dateFormatter = DateFormatter()

    var dataSource: [TrackingModel] = [] {
        didSet {
            if !isViewLoaded { return }
            tableView.reloadData()
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
        let trackingEvent = dataSource[indexPath.row]
        cell.titleLabel.text = trackingEvent.title
        cell.subtitleLabel.text = "$\(PriceFormatter.string(from: trackingEvent.amount))"
        cell.dateLabel.text = dateFormatter.string(from: trackingEvent.createdAt)
        cell.statusIndicator.backgroundColor = UIColor(hex: "#f3f3f3")
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
