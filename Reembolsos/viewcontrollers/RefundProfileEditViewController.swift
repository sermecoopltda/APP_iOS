//
//  RefundProfileEditViewController.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/19/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

private protocol RefundProfileEditTableViewSectionEnum {
    var title: String? { get }
    var defaultValue: String? { get }
}

extension RefundProfileEditTableViewSectionEnum {
    var defaultValue: String? { return nil }
}

private enum RefundProfileEditTableViewSection: Int {
    case editable
    case noneditable
    case count

    init(_ rawValue: Int) {
        self = RefundProfileEditTableViewSection(rawValue: rawValue) ?? .editable
    }

    var title: String? {
        switch self {
        case .editable: return "Datos Personales"
        case .noneditable: return "Cuenta Corriente"
        default: return nil
        }
    }

    var rowCount: Int {
        switch self {
        case .editable: return RefundProfileEditTableViewEditableSectionRow.count.rawValue
        case .noneditable: return RefundProfileEditTableViewNoneditableSectionRow.count.rawValue
        default: return 0
        }
    }

    func row(_ row: Int) -> RefundProfileEditTableViewSectionEnum {
        if self == .editable {
            return RefundProfileEditTableViewEditableSectionRow(row)
        }
        return RefundProfileEditTableViewNoneditableSectionRow(row)
    }
}

private enum RefundProfileEditTableViewEditableSectionRow: Int, RefundProfileEditTableViewSectionEnum {
    case name
    case phoneNumber
    case email
    case count

    init(_ rawValue: Int) {
        self = RefundProfileEditTableViewEditableSectionRow(rawValue: rawValue) ?? .name
    }

    var title: String? {
        switch self {
        case .name: return "Nombre"
        case .phoneNumber: return "Teléfono"
        case .email: return "E-mail"
        default: return nil
        }
    }

    var defaultValue: String? {
        switch self {
        case .name: return "Juan Pérez"
        case .phoneNumber: return "987654321"
        case .email: return "juan.perez@hotmail.com"
        default: return nil
        }
    }

}

private enum RefundProfileEditTableViewNoneditableSectionRow: Int, RefundProfileEditTableViewSectionEnum {
    case bankingProduct
    case accountNumber
    case bankName
    case count

    init(_ rawValue: Int) {
        self = RefundProfileEditTableViewNoneditableSectionRow(rawValue: rawValue) ?? .bankingProduct
    }

    var title: String? {
        switch self {
        case .bankingProduct: return "Producto"
        case .accountNumber: return "Nº de Cuenta"
        case .bankName: return "Banco"
        default: return nil
        }
    }

    var defaultValue: String? {
        switch self {
        case .bankingProduct: return "Cuenta Corriente"
        case .accountNumber: return "0987654321"
        case .bankName: return "De La Plaza"
        default: return nil
        }
    }

}

class RefundProfileEditViewController: UIViewController {
    private struct statics {
        static let cellIdentifier = "cellIdentifier"
    }

    @IBOutlet var tableView: UITableView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var phoneTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var defaultTextField: UITextField!
    @IBOutlet var callButton: UIButton!
    @IBOutlet var tableFooterView: UIView!

    fileprivate var textfields: [IndexPath: UITextField] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Confirmar Datos"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Siguiente", style: .done, target: self, action: #selector(RefundProfileEditViewController.next(_:)))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tableView.register(UINib(nibName: String(describing: ProfileEditTableViewCell.self), bundle: nil), forCellReuseIdentifier: statics.cellIdentifier)
        tableView.tableFooterView = tableFooterView
        NotificationCenter.default.addObserver(self, selector: #selector(RefundProfileEditViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RefundProfileEditViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        callButton.layer.cornerRadius = callButton.bounds.size.height / 2
        callButton.layer.borderWidth = 2
        callButton.layer.borderColor = UIColor(hex: "#333333").cgColor
        // NotificationCenter.default.addObserver(self, selector: #selector(RefundProfileEditViewController.textFieldTextDidChange(_:)), name: UITextField.textDidChangeNotification, object: nil)
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

    fileprivate func textField(for indexPath: IndexPath) -> UITextField? {
        switch RefundProfileEditTableViewSection(indexPath.section) {
        case .editable:
            switch RefundProfileEditTableViewEditableSectionRow(indexPath.row) {
            case .name: return nameTextField
            case .phoneNumber: return phoneTextField
            case .email: return emailTextField
            default: return nil
            }

        case .noneditable:
            if let textField = textfields[indexPath] {
                return textField
            }
            let textField = defaultTextField.copyView() as! UITextField
            textfields[indexPath] = textField
            return textField

        default: return nil
        }

    }

    // MARK: Control Actions

    @objc func next(_ sender: Any) {
        let controller = RefundRequestViewController()
        navigationController?.pushViewController(controller, animated: true)
    }

    // MARK: Notification Handlers

    @objc func keyboardWillShow(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let animationCurveInt = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
            let animationCurve = UIView.AnimationCurve(rawValue: animationCurveInt)
            else {
                return
        }
        UIView.animate(withDuration: animationDuration,
                       delay: 0,
                       options: UIView.AnimationOptions(curve: animationCurve),
                       animations: {
                        self.tableView.contentInset.bottom = keyboardFrame.size.height
                        self.tableView.scrollIndicatorInsets.bottom = keyboardFrame.size.height
        },
                       completion: nil)
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let animationCurveInt = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
            let animationCurve = UIView.AnimationCurve(rawValue: animationCurveInt)
            else {
                return
        }
        UIView.animate(withDuration: animationDuration,
                       delay: 0,
                       options: UIView.AnimationOptions(curve: animationCurve),
                       animations: {
                        self.tableView.contentInset.bottom = 0
                        self.tableView.scrollIndicatorInsets.bottom = 0
        },
                       completion: nil)
    }
}

// MARK: - <UITableViewDataSource> Methods

extension RefundProfileEditViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return RefundProfileEditTableViewSection.count.rawValue
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RefundProfileEditTableViewSection(section).rowCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: statics.cellIdentifier, for: indexPath) as! ProfileEditTableViewCell
        let section = RefundProfileEditTableViewSection(indexPath.section)
        let row = section.row(indexPath.row)
        cell.titleLabel.text = row.title
        cell.textField = textField(for: indexPath)
        cell.textField?.text = row.defaultValue
        cell.isEditable = section == .editable
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return RefundProfileEditTableViewSection(section).title
    }
}

// MARK: - <UITableViewDelegate> Methods

extension RefundProfileEditViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if RefundProfileEditTableViewSection(indexPath.section) == .editable { return indexPath }
        return nil
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        textField(for: indexPath)?.becomeFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
