//
//  HistoryDetailViewController.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/28/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

private enum HistoryDetailTableViewSection: Int {
    case general
    case detail
    case notes
    case transaction
    case count

    init(_ rawValue: Int) {
        self = HistoryDetailTableViewSection(rawValue: rawValue) ?? .general
    }

    var title: String? {
        switch self {
        case .detail: return "Detalle Reembolso"
        case .notes: return "Observaciones"
        default: return nil
        }
    }

    var numberOfRows: Int {
        switch self {
        case .general: return HistoryDetailTableViewGeneralSectionRow.count.rawValue
        case .detail: return HistoryDetailTableViewDetailSectionRow.count.rawValue
        case .notes: return 1
        case .transaction: return 1
        default: return 0
        }
    }
}

private enum HistoryDetailTableViewGeneralSectionRow: Int {
    case date
    case identifier
    case beneficiary
    case count

    init(_ rawValue: Int) {
        self = HistoryDetailTableViewGeneralSectionRow(rawValue: rawValue) ?? .date
    }

    var title: String? {
        switch self {
        case .date: return "Fecha"
        case .identifier: return "Folio"
        case .beneficiary: return "Beneficiario"
        default: return nil
        }
    }
}

private enum HistoryDetailTableViewDetailSectionRow: Int {
    case total
    case healthcare
    case client
    case count

    init(_ rawValue: Int) {
        self = HistoryDetailTableViewDetailSectionRow(rawValue: rawValue) ?? .total
    }

    var title: String? {
        switch self {
        case .total: return "Valor Total"
        case .healthcare: return "Sistema de Salud"
        case .client: return "Costo Socio"
        default: return nil 
        }
    }
}

class HistoryDetailViewController: UIViewController {
    private struct statics {
        static let cellIdentifier = "cellIdentifier"
        static let textCellIdentifier = "textCellIdentifier"
    }

    @IBOutlet var tableView: UITableView!
    @IBOutlet var badgeImageView: UIImageView!
    @IBOutlet var totalLabel: UILabel!
    @IBOutlet var detailsButton: UIButton!
    @IBOutlet var tableFooterView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var notesTextView: UITextView!

    var identifier: String?

    fileprivate var detail: HistoricDetailModel? {
        didSet {
            guard isViewLoaded, let detail = detail else { return }
            totalLabel.text = "$\(PriceFormatter.string(from: detail.bonification))"
            tableView.reloadData()
            notesTextView.text = detail.notes ?? ""
        }
    }

    fileprivate let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Detalle de Transacción"
        dateFormatter.setLocalizedDateFormatFromTemplate("dMMyyyy")
        // navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "mail-icon"), style: .plain, target: nil, action: nil)
        badgeImageView.tintColor = UIColor(hex: "#009e10")
        tableView.register(UINib(nibName: String(describing: TrackingTableViewCell.self), bundle: nil), forCellReuseIdentifier: statics.cellIdentifier)
        tableView.register(UINib(nibName: String(describing: RefundTextTableViewCell.self), bundle: nil), forCellReuseIdentifier: statics.textCellIdentifier)

        tableView.isHidden = true
        activityIndicator.startAnimating()

        guard let identifier = identifier else { return }
        APIClient.shared.historic(identifier: identifier, completionHandler: {
            (success: Bool, historicDetail: HistoricDetailModel?) in
            self.activityIndicator.stopAnimating()
            if success, let historicDetail = historicDetail {
                self.detail = historicDetail
                self.tableView.isHidden = false
            } else {
                // error alert
            }
        })

        guard let font = detailsButton.titleLabel?.font, let color = detailsButton.titleColor(for: .normal), let title = detailsButton.title(for: .normal) else { return }
        var attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        let attributedString = NSAttributedString(string: title, attributes: attributes)
        detailsButton.setAttributedTitle(attributedString, for: .normal)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let tableFooterView = tableView.tableFooterView else { return }
        let fittingSize = tableFooterView.systemLayoutSizeFitting(view.bounds.size, withHorizontalFittingPriority: .defaultHigh, verticalFittingPriority: .defaultLow)
        if tableFooterView.frame.size.height != fittingSize.height {
            tableFooterView.frame.size.height = fittingSize.height
            tableView.tableFooterView = tableFooterView
            tableFooterView.layoutIfNeeded()
        }
    }

    // MARK: - Control Actions

    @IBAction func detailsButtonTouched(_ sender: Any) {
        guard let detailURL = detail?.detailURL, UIApplication.shared.canOpenURL(detailURL) else { return }
        UIApplication.shared.open(detailURL, options: [:], completionHandler: nil)
    }
}

// MARK: - <UITableViewDataSource> Methods

extension HistoryDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return detail == nil ? 0 : HistoryDetailTableViewSection.count.rawValue
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detail == nil ? 0 : HistoryDetailTableViewSection(section).numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let detail = detail else { return UITableViewCell() }
        switch HistoryDetailTableViewSection(indexPath.section) {
        case .general:
            let cell = tableView.dequeueReusableCell(withIdentifier: statics.cellIdentifier, for: indexPath) as! TrackingTableViewCell
            let row = HistoryDetailTableViewGeneralSectionRow(indexPath.row)
            cell.textLabel?.text = row.title
            switch row {
            case .date: cell.detailTextLabel?.text = dateFormatter.string(from: detail.date)
            case .identifier: cell.detailTextLabel?.text = detail.identifier
            case .beneficiary: cell.detailTextLabel?.text = detail.beneficiary
            default: ()
            }
            return cell

        case .detail:
            let cell = tableView.dequeueReusableCell(withIdentifier: statics.cellIdentifier, for: indexPath) as! TrackingTableViewCell
            let row = HistoryDetailTableViewDetailSectionRow(indexPath.row)
            cell.textLabel?.text = row.title
            switch row {
            case .total: cell.detailTextLabel?.text = "$\(PriceFormatter.string(from: detail.total))"
            case .healthcare: cell.detailTextLabel?.text = "$\(PriceFormatter.string(from: detail.healthcare))"
            case .client: cell.detailTextLabel?.text = "$\(PriceFormatter.string(from: detail.clientCost))"
            default: ()
            }
            return cell

        case .notes:
            let cell = tableView.dequeueReusableCell(withIdentifier: statics.textCellIdentifier, for: indexPath) as! RefundTextTableViewCell
            cell.textView = notesTextView
            return cell

        case .transaction:
            let cell = tableView.dequeueReusableCell(withIdentifier: statics.cellIdentifier, for: indexPath) as! TrackingTableViewCell
            cell.textLabel?.text = "Transacción"
            cell.detailTextLabel?.text = detail.transaction
            return cell

        default: return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return HistoryDetailTableViewSection(section).title
    }
}

// MARK: - <UITableViewDelegate> Methods

extension HistoryDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch HistoryDetailTableViewSection(indexPath.section) {
        case .notes: return 78
        default: return tableView.rowHeight
        }
    }
}

