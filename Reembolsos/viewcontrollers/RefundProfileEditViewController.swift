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
//    var defaultValue: String? { get }
}

//
//extension RefundProfileEditTableViewSectionEnum {
//    var defaultValue: String? { return nil }
//}

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
        case .phoneNumber: return "Celular"
        case .email: return "E-mail"
        default: return nil
        }
    }
}

private enum RefundProfileEditTableViewNoneditableSectionRow: Int, RefundProfileEditTableViewSectionEnum {
//    case bankingProduct
    case accountNumber
    case bankName
    case count

    init(_ rawValue: Int) {
        self = RefundProfileEditTableViewNoneditableSectionRow(rawValue: rawValue) ?? .accountNumber
    }

    var title: String? {
        switch self {
//        case .bankingProduct: return "Producto"
        case .accountNumber: return "Nº de Cuenta"
        case .bankName: return "Banco"
        default: return nil
        }
    }

//    var defaultValue: String? {
//        switch self {
//        case .bankingProduct: return "Cuenta Corriente"
//        case .accountNumber: return "0987654321"
//        case .bankName: return "De La Plaza"
//        default: return nil
//        }
//    }
}

class RefundProfileEditViewController: UIViewController {
    private struct statics {
        static let cellIdentifier = "cellIdentifier"
    }

    @IBOutlet var tableView: UITableView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var phoneTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var bankTextField: UITextField!
    @IBOutlet var accountTextField: UITextField!
    @IBOutlet var callButton: UIButton!
    @IBOutlet var tableFooterView: UIView!

    fileprivate var user: UserModel? {
        didSet {
            if !isViewLoaded { return }
            nameTextField.text = user?.name
            emailTextField.text = user?.email
            phoneTextField.text = user?.phoneNumber
            bankTextField.text = user?.bankName
            accountTextField.text = "**\(user?.bankAccount.suffix(4) ?? "")"

            self.conditionallyEnableNextButton()
            // tableView.reloadData()
        }
    }

    fileprivate var nextButtonItem: UIBarButtonItem {
        return UIBarButtonItem(title: "Siguiente", style: .done, target: self, action: #selector(RefundProfileEditViewController.next(_:)))
    }

    fileprivate var textfields: [IndexPath: UITextField] = [:]
    var benefitRules: BenefitRulesModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Actualizar Datos"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tableView.register(UINib(nibName: String(describing: ProfileEditTableViewCell.self), bundle: nil), forCellReuseIdentifier: statics.cellIdentifier)
        tableView.tableFooterView = tableFooterView
        NotificationCenter.default.addObserver(self, selector: #selector(RefundProfileEditViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RefundProfileEditViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RefundProfileEditViewController.textFieldTextDidChange(_:)), name: UITextField.textDidChangeNotification, object: nil)
        callButton.layer.cornerRadius = callButton.bounds.size.height / 2
        callButton.layer.borderWidth = 2
        callButton.layer.borderColor = UIColor(hex: "#333333").cgColor

        refreshProfile()
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

    private func refreshProfile() {
        let activityIndicator = UIActivityIndicatorView(style: .white)
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        APIClient.shared.profile(completionHandler: {
            (success: Bool, user: UserModel?) in
            activityIndicator.stopAnimating()
            if success, let user = user {
                self.user = user
                self.navigationItem.rightBarButtonItem = self.nextButtonItem
                self.conditionallyEnableNextButton()
            } else {
                let controller = UIAlertController(title: "Error Obteniendo Datos", message: "Ocurrió un error al obtener los datos del usuario. Por favor revisa tus ajustes de red e intenta nuevamente.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
                controller.addAction(okAction)
                self.present(controller, animated: true, completion: nil)
            }
        })
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
            switch RefundProfileEditTableViewNoneditableSectionRow(indexPath.row) {
            case .bankName: return bankTextField
            case .accountNumber: return accountTextField
            default: return nil
            }
        default: return nil
        }
    }

    fileprivate func conditionallyEnableNextButton() {
        let textFields: [UITextField] = [nameTextField, phoneTextField, emailTextField]
        for textField in textFields {
            guard let text = textField.text, text.count > 0 else {
                navigationItem.rightBarButtonItem?.isEnabled = false
                return
            }
        }
        navigationItem.rightBarButtonItem?.isEnabled = true
    }

    private func failWithError(title: String, message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }

    // MARK: Control Actions

    @objc func next(_ sender: Any) {
        view.endEditing(true)
        guard let email = emailTextField.text, let phoneNumber = phoneTextField.text else { return }
        if !Validator.isValidEmail(email) {
            failWithError(title: "Error Validando E-mail", message: "La dirección de e-mail ingresada no es válida.")
            return
        }
        if !Validator.isValidPhoneNumber(phoneNumber) {
            failWithError(title: "Error Validando Teléfono", message: "El número telefónico ingresado no es válido: debe contener sólo 9 dígitos.")
            return
        }

        tableView.isUserInteractionEnabled = false
        navigationItem.hidesBackButton = true
        let activityIndicator = UIActivityIndicatorView(style: .white)
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        APIClient.shared.updateProfile(name: nameTextField.text, phoneNumber: phoneNumber, email: email, completionHandler: {
            (success: Bool) in
            self.navigationItem.hidesBackButton = false
            self.tableView.isUserInteractionEnabled = true
            self.navigationItem.rightBarButtonItem = self.nextButtonItem
            self.conditionallyEnableNextButton()
            if success {
                let controller = RefundRequestViewController()
                controller.benefitRules = self.benefitRules
                self.navigationController?.pushViewController(controller, animated: true)
            } else {
                let controller = UIAlertController(title: "Error Guardando Datos", message: "Ocurrió un error al almacenar los datos del usuario. Por favor revisa tus ajustes de red e intenta nuevamente.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
                controller.addAction(okAction)
                self.present(controller, animated: true, completion: nil)
            }
        })
    }

    @IBAction func callButtonTouched(_ sender: Any) {
        let callURL = URL(string: "tel:6006558000")!
        if UIApplication.shared.canOpenURL(callURL) {
            UIApplication.shared.open(callURL, options: [:], completionHandler: nil)
        }
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

    @objc func textFieldTextDidChange(_ notification: Notification) {
        NSLog("textFieldTextDidChange")
        conditionallyEnableNextButton()
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
        if indexPath.section == RefundProfileEditTableViewSection.editable.rawValue && indexPath.row == RefundProfileEditTableViewEditableSectionRow.name.rawValue {
            cell.isEditable = false
        } else {
            cell.isEditable = section == .editable
        }
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
