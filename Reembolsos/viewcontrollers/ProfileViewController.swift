//
//  ProfileViewController.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/14/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

private enum ProfileTableViewSection: Int {
    case personal
    case plan
    case count

    init(_ rawValue: Int) {
        self = ProfileTableViewSection(rawValue: rawValue) ?? .personal
    }

    var numberOfRows: Int {
        switch self {
        case .personal: return ProfileTableViewSectionPersonalRow.count.rawValue
        case .plan: return ProfileTableViewSectionPlanRow.count.rawValue
        default: return 0
        }
    }

    var title: String? {
        switch self {
        case .personal: return "Datos Personales"
        default: return nil
        }
    }
}

private enum ProfileTableViewSectionPersonalRow: Int {
    case name
    case phoneNumber
    case email
    case count

    init(_ rawValue: Int) {
        self = ProfileTableViewSectionPersonalRow(rawValue: rawValue) ?? .name
    }

    var title: String? {
        switch self {
        case .name: return "Nombre"
        case .phoneNumber: return "Teléfono"
        case .email: return "E-mail"
        default: return nil
        }
    }
}

private enum ProfileTableViewSectionPlanRow: Int {
    case company
    case name
    case exclusions
    case count

    init(_ rawValue: Int) {
        self = ProfileTableViewSectionPlanRow(rawValue: rawValue) ?? .name
    }

    var title: String? {
        switch self {
        case .company: return "Empresa"
        case .name: return "Plan"
        case .exclusions: return "Exclusiones de Cobertura"
        default: return nil
        }
    }
}

class ProfileViewController: UIViewController {
    private struct statics {
        static let cellIdentifier = "cellIdentifier"
    }
    
    @IBOutlet var tableView: UITableView!

    fileprivate var user: UserModel? {
        didSet {
            guard isViewLoaded, user != nil else { return }
            tableView.reloadData()
        }
    }

    private let refreshControl = UIRefreshControl()

    convenience init() {
        self.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: "Mi Perfil", image: #imageLiteral(resourceName: "tabBar-profile"), tag: 2)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.addTarget(self, action: #selector(ProfileViewController.refreshControlValueChanged(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.register(UINib(nibName: String(describing: ProfileTableViewCell.self), bundle: nil), forCellReuseIdentifier: statics.cellIdentifier)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Actualizar", style: .plain, target: self, action: #selector(ProfileViewController.edit(_:)))
        navigationItem.title = "Mi Perfil"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !refreshControl.isRefreshing {
            refreshData()
        }
    }

    private func refreshData() {
        refreshControl.beginRefreshing()
        APIClient.shared.profile(completionHandler: {
            (success: Bool, user: UserModel?) in
            if success, let user = user {
                self.user = user
            }
            self.refreshControl.endRefreshing()
        })
    }

    @objc func refreshControlValueChanged(_ sender: Any) {
        if refreshControl.isRefreshing {
            refreshData()
        }
    }

    @objc func edit(_ sender: Any) {
        let controller = ProfileEditViewController()
        let navController = NavigationController(rootViewController: controller)
        present(navController, animated: true, completion: nil)
    }
}

// MARK: - <UITableViewDataSource> Methods

extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return user == nil ? 0 : ProfileTableViewSection.count.rawValue
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if user == nil { return 0 }
        return ProfileTableViewSection(section).numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: statics.cellIdentifier, for: indexPath) as! ProfileTableViewCell
        switch ProfileTableViewSection(indexPath.section) {
        case .personal:
            let row = ProfileTableViewSectionPersonalRow(indexPath.row)
            cell.titleLabel.text = row.title
            switch row {
            case .name: cell.detailLabel.text = user?.name
            case .email: cell.detailLabel.text = user?.email
            case .phoneNumber: cell.detailLabel.text = user?.phoneNumber
            default: ()
            }

        case .plan:
            let row = ProfileTableViewSectionPlanRow(indexPath.row)
            cell.titleLabel.text = row.title
            switch row {
            case .company: cell.detailLabel.text = user?.companyName
            case .name:
                cell.detailLabel.text = user?.planName
                cell.accessoryType = .disclosureIndicator
            case .exclusions: cell.accessoryType = .disclosureIndicator
            default: ()
            }

        default: ()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ProfileTableViewSection(section).title
    }
}

// MARK: - <UITableViewDelegate> Methods

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch ProfileTableViewSection(indexPath.section) {
        case .plan:
            let row = ProfileTableViewSectionPlanRow(indexPath.row)
            switch row {
            case .name:
                if let planURL = user?.planURL, UIApplication.shared.canOpenURL(planURL) {
                    UIApplication.shared.open(planURL, options: [:], completionHandler: nil)
                }

            case .exclusions:
                if let exclusionsURL = user?.exclusionsURL, UIApplication.shared.canOpenURL(exclusionsURL) {
                    UIApplication.shared.open(exclusionsURL, options: [:], completionHandler: nil)
                }

            default: ()
            }

        default: ()
        }
    }
}
