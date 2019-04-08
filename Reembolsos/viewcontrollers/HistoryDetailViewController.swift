//
//  HistoryDetailViewController.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/28/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

class HistoryDetailViewController: UIViewController {
    private struct statics {
        static let cellIdentifier = "cellIdentifier"
    }

    @IBOutlet var tableView: UITableView!
    @IBOutlet var badgeImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Detalle de Transacción"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "mail-icon"), style: .plain, target: nil, action: nil)
        badgeImageView.tintColor = UIColor(hex: "#009e10")
        tableView.register(UINib(nibName: String(describing: TrackingTableViewCell.self), bundle: nil), forCellReuseIdentifier: statics.cellIdentifier)
    }
}

// MARK: - <UITableViewDataSource> Methods

extension HistoryDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return 3
        case 2: return 4
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: statics.cellIdentifier, for: indexPath)
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Fecha"
                cell.detailTextLabel?.text = "13/01/2019 12:34"

            case 1:
                cell.textLabel?.text = "Nro Transacción"
                cell.detailTextLabel?.text = "12345678"

            default: ()
            }

        case 1:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Producto"
                cell.detailTextLabel?.text = "Cuenta Corriente"

            case 1:
                cell.textLabel?.text = "Nro Cuenta"
                cell.detailTextLabel?.text = "0987654321"

            case 2:
                cell.textLabel?.text = "Banco"
                cell.detailTextLabel?.text = "De La Plaza"

            default: ()
            }

        case 2:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Nombre Titular"
                cell.detailTextLabel?.text = "Juan Pérez"

            case 1:
                cell.textLabel?.text = "RUT"
                cell.detailTextLabel?.text = "12.345.678-9"

            case 2:
                cell.textLabel?.text = "Nro. Cuenta"
                cell.detailTextLabel?.text = "0987654321"

            case 3:
                cell.textLabel?.text = "Banco"
                cell.detailTextLabel?.text = "De La Plaza"

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
        case 1: return "Origen"
        case 2: return "Destino"
        default: return nil
        }
    }
}
