//
//  TransactionDetailViewController.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/28/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

private enum TransactionDetailTableViewSection: Int {
    case data
    case documents
    case notes
    case count

    init(_ rawValue: Int) {
        self = TransactionDetailTableViewSection(rawValue: rawValue) ?? .data
    }

    var title: String? {
        switch self {
        case .documents: return "Documentos"
        case .notes: return "Observaciones"
        default: return nil 
        }
    }
}

private enum TransactionDetailTableViewDataRow: Int {
    case identifier
    case createdAt
    case amount
    case beneficiary
    case benefit
    case count

    init(_ rawValue: Int) {
        self = TransactionDetailTableViewDataRow(rawValue: rawValue) ?? .createdAt
    }

    var title: String? {
        switch self {
        case .identifier: return "Nº de Folio"
        case .createdAt: return "Fecha Ingreso"
        case .amount: return "Monto"
        case .beneficiary: return "Beneficiario"
        case .benefit: return "Tipo de Prestación"
        default: return nil
        }
    }
}

class TransactionDetailViewController: UIViewController {
    private struct statics {
        static let cellIdentifier = "cellIdentifier"
        static let documentCellIdentifier = "documentCellIdentifier"
        static let textCellIdentifier = "textCellIdentifier"
    }

    @IBOutlet var statusIndicatorView: StatusIndicatorView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableFooterView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var notesTextView: UITextView!

    var identifier: String?

    fileprivate let dateFormatter = DateFormatter()

    fileprivate var transactionDetail: TransactionDetailModel? {
        didSet {
            guard isViewLoaded, let transactionDetail = transactionDetail else { return }
            NSLog("transactionDetail.notes: \(transactionDetail.notes)")
            // populate UI
            tableView.isHidden = false
            statusIndicatorView.isHidden = false

            switch transactionDetail.status {
            case .submitted:
                statusIndicatorView.currentState = .started
                statusIndicatorView.setTitle(transactionDetail.statusText, for: .started)

            case .rejected:
                statusIndicatorView.currentState = .ended
                statusIndicatorView.setTitle(transactionDetail.statusText, for: .ended)

            case .accepted:
                statusIndicatorView.currentState = .ended
                statusIndicatorView.setTitle(transactionDetail.statusText, for: .ended)

            default:
                statusIndicatorView.currentState = .intermediate
                statusIndicatorView.setTitle(transactionDetail.statusText, for: .intermediate)
            }

            statusIndicatorView.currentStateColor = transactionDetail.status.backgroundColor

            notesTextView.text = transactionDetail.notes ?? ""

            tableView.reloadData()
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.setLocalizedDateFormatFromTemplate("dMMMHm")
        navigationItem.title = "Estado de Solicitud"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tableView.register(UINib(nibName: String(describing: TrackingTableViewCell.self), bundle: nil), forCellReuseIdentifier: statics.cellIdentifier)
        tableView.register(UINib(nibName: String(describing: RefundDocumentTableViewCell.self), bundle: nil), forCellReuseIdentifier: statics.documentCellIdentifier)
        tableView.register(UINib(nibName: String(describing: RefundTextTableViewCell.self), bundle: nil), forCellReuseIdentifier: statics.textCellIdentifier)

        statusIndicatorView.isHidden = true
        tableView.isHidden = true
        activityIndicator.startAnimating()

        guard let identifier = identifier else { return }
        APIClient.shared.transaction(identifier: identifier, completionHandler: {
            (success: Bool, detail: TransactionDetailModel?) in
            self.activityIndicator.stopAnimating()
            if success, let detail = detail {
                self.transactionDetail = detail
            } else {
                // error alert
                let controller = UIAlertController(title: "Error Obteniendo Detalles",
                                                   message: "Ocurrió un error al intentar obtener los detalles de la transacción. Por favor intenta nuevamente.",
                                                   preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Aceptar", style: .default, handler: {
                    _ in
                    self.navigationController?.popViewController(animated: true)
                })
                controller.addAction(okAction)
                self.present(controller, animated: true, completion: nil)
            }
        })
    }
}

// MARK: - <UITableViewDataSource> Methods

extension TransactionDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return transactionDetail == nil ? 0 : TransactionDetailTableViewSection.count.rawValue
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch TransactionDetailTableViewSection(section) {
        case .data: return TransactionDetailTableViewDataRow.count.rawValue
        case .documents: return transactionDetail?.documents.count ?? 0
        case .notes: return 1
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch TransactionDetailTableViewSection(indexPath.section) {
        case .data:
            let cell = tableView.dequeueReusableCell(withIdentifier: statics.cellIdentifier, for: indexPath) as! TrackingTableViewCell
            let row = TransactionDetailTableViewDataRow(indexPath.row)
            cell.textLabel?.text = row.title
            if let transactionDetail = transactionDetail {
                switch row {
                case .identifier: cell.detailTextLabel?.text = transactionDetail.identifier
                case .createdAt: cell.detailTextLabel?.text = dateFormatter.string(from: transactionDetail.createdAt)
                case .amount: cell.detailTextLabel?.text = "$\(PriceFormatter.string(from: transactionDetail.amount))"
                case .beneficiary: cell.detailTextLabel?.text = transactionDetail.beneficiary
                case .benefit: cell.detailTextLabel?.text = transactionDetail.benefitName
                default: ()
                }
            }
            return cell

        case .documents:
            let cell = tableView.dequeueReusableCell(withIdentifier: statics.documentCellIdentifier, for: indexPath) as! RefundDocumentTableViewCell
            let document = transactionDetail?.documents[indexPath.row]
            cell.titleLabel.text = document?.name
            cell.showsIcon = false
            cell.accessoryType = .none
            if let imageURL = document?.url {
                cell.documentImage = AssetsClient.shared.image(dataForURL: imageURL)
                if cell.documentImage == nil {
                    AssetsClient.shared.fetch(URL: imageURL, completionHandler: {
                        (data: Data?) in
                        if let data = data, UIImage(data: data) != nil {    
                            tableView.reloadRows(at: [indexPath], with: .none)
                        }
                    })
                } else {
                    cell.accessoryType = .disclosureIndicator
                }
            }
            return cell

        case .notes:
            let cell = tableView.dequeueReusableCell(withIdentifier: statics.textCellIdentifier, for: indexPath) as! RefundTextTableViewCell
            cell.textView = notesTextView
            return cell

        default: return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return TransactionDetailTableViewSection(section).title
    }
}

// MARK: - <UITableViewDelegate> Methods

extension TransactionDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch TransactionDetailTableViewSection(indexPath.section) {
        case .documents: return UITableView.automaticDimension
        case .notes: return 78
        default: return tableView.rowHeight
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch TransactionDetailTableViewSection(indexPath.section) {
        case .documents:
            let document = transactionDetail?.documents[indexPath.row]
            let controller = DocumentViewController()
            controller.document = document
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)

        default: ()
        }
    }
}
