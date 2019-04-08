//
//  TrackingDetailViewController.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/28/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

class TrackingDetailViewController: UIViewController {
    private struct statics {
        static let cellIdentifier = "cellIdentifier"
    }

    @IBOutlet var statusIndicatorView: StatusIndicatorView!
    @IBOutlet var tableFooterView: UIView!
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Estado de Solicitud"
        tableView.register(UINib(nibName: String(describing: TrackingTableViewCell.self), bundle: nil), forCellReuseIdentifier: statics.cellIdentifier)
        statusIndicatorView.currentState = .ended
        statusIndicatorView.currentStateColor = UIColor(hex: "#009e10")
        statusIndicatorView.setTitle("Ingresada", for: .started)
        statusIndicatorView.setTitle("Aceptada", for: .ended)
    }
}

// MARK: - <UITableViewDataSource> Methods

extension TrackingDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 4
        case 1: return 1
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: statics.cellIdentifier, for: indexPath)
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Fecha Ingreso"
                cell.detailTextLabel?.text = "Ayer"

            case 1:
                cell.textLabel?.text = "Monto"
                cell.detailTextLabel?.text = "$25.000"

            case 2:
                cell.textLabel?.text = "Beneficiario"
                cell.detailTextLabel?.text = "Juan Pérez"

            case 3:
                cell.textLabel?.text = "Tipo Prestación"
                cell.detailTextLabel?.text = "Consulta"

            default: ()
            }

        default:
            cell.textLabel?.text = nil
            cell.detailTextLabel?.text = nil
        }
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return "Observaciones"
        case 2: return "Boleta / Bono"
        default: return nil
        }
    }
}

// MARK: - <UITableViewDelegate> Methods

extension TrackingDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? tableView.rowHeight : tableView.rowHeight * 2
    }
}
