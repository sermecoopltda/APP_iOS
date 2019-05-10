//
//  TransactionsHistoryViewController.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/20/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

class TransactionsHistoryViewController: UIViewController {
    private struct statics {
        static let cellIdentifier = "cellIdentifier"
    }
    @IBOutlet var tableView: UITableView!
    @IBOutlet var calendarButton: UIButton!
    @IBOutlet var dateButton: UIButton!
    @IBOutlet var emptyStateView: UIView!
    @IBOutlet var emptyStateLabel: UILabel!
    @IBOutlet var emptyStateImageView: UIImageView!

    let dateFormatter = DateFormatter()

    var dataSource: [HistoricModel] = [] {
        didSet {
            if !isViewLoaded { return }
            tableView.reloadData()
            tableView.backgroundView = dataSource.count == 0 ? emptyStateView : nil
        }
    }

    let refreshControl = UIRefreshControl()

    private var date: Date? {
        didSet {
            guard isViewLoaded, let date = date else { return }
            let formatter = DateFormatter()
            formatter.setLocalizedDateFormatFromTemplate("MMMMyyyy")
            dateButton.setTitle(formatter.string(from: date).localizedFirstCapitalized, for: .normal)
        }
    }

    convenience init() {
        self.init(nibName: nil, bundle: nil)
        dateFormatter.setLocalizedDateFormatFromTemplate("dMMMHm")
        navigationItem.title = "Historial"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: String(describing: HistoricTableViewCell.self), bundle: nil), forCellReuseIdentifier: statics.cellIdentifier)
        tableView.tableFooterView = UIView(frame: .zero)
        emptyStateImageView.tintColor = .lightGray

        refreshControl.addTarget(self, action: #selector(TransactionsHistoryViewController.refreshControlValueChanged(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl

        dateButton.titleLabel?.font = UIFont.boldAppFont(ofSize: 17)
        
        date = Date()
        refreshData()
    }

    private func refreshData() {
        guard let date = date else { return }
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        refreshControl.beginRefreshing()
        APIClient.shared.history(month: month, year: year, completionHandler: {
            (success: Bool, historicEvents: [HistoricModel]) in
            if success {
                self.dataSource = historicEvents
            }
            self.refreshControl.endRefreshing()
        })
    }

    @objc func refreshControlValueChanged(_ sender: Any) {
        if refreshControl.isRefreshing {
            refreshData()
        }
    }

    @IBAction func calendarButtonTouched(_ sender: Any) {
        let controller = CalendarViewController(mode: .history)
        controller.date = date
        controller.dismissHandler = {
            (events: [DateDrivenEntryProtocol], date: Date?) in
            self.dataSource = events as? [HistoricModel] ?? []
            if let date = date {
                self.date = date
            }
        }
        let navController = NavigationController(rootViewController: controller)
        present(navController, animated: true, completion: nil)
    }
}

// MARK: - <UITableViewDataSource> Methods

extension TransactionsHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: statics.cellIdentifier, for: indexPath) as! HistoricTableViewCell
        let historic = dataSource[indexPath.row]
        cell.titleLabel.text = historic.title
        cell.subtitleLabel.text = "$\(PriceFormatter.string(from: historic.amount))"
        cell.dateLabel.text = dateFormatter.string(from: historic.createdAt)
        return cell
    }
}

// MARK: - <UITableViewDelegate> Methods

extension TransactionsHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let historic = dataSource[indexPath.row]
        let controller = HistoryDetailViewController()
        controller.identifier = historic.identifier
        navigationController?.pushViewController(controller, animated: true)
    }
}
