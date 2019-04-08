//
//  RefundRequestViewController.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/19/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

private enum RefundRequestTableViewSection: Int {
    case beneficiary
    case benefit
    case amount
    case images
    case notes
    case count

    init(_ rawValue: Int) {
        self = RefundRequestTableViewSection(rawValue: rawValue) ?? .beneficiary
    }

    var title: String? {
        switch self {
        case .beneficiary: return "Beneficiario"
        case .benefit: return "Tipo de Prestación"
        case .notes: return "Observaciones"
        default: return nil
        }
    }
}
class RefundRequestViewController: UIViewController {
    private struct statics {
        static let defaultCellIdentifier = "defaultCellIdentifier"
        static let textFieldCellIdentifier = "textFieldCellIdentifier"
        static let textViewCellIdentifier = "textViewCellIdentifier"
        static let beneficiaries = ["Juan Pérez", "María González"]
    }

    @IBOutlet var tableView: UITableView!
    @IBOutlet var amountTextField: UITextField!
    @IBOutlet var textView: UITextView!
    @IBOutlet var notesTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Nuevo Reembolso"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Enviar", style: .done, target: self, action: #selector(RefundRequestViewController.submit(_:)))

        tableView.register(UINib(nibName: String(describing: RefundRequestTableViewCell.self), bundle: nil), forCellReuseIdentifier: statics.defaultCellIdentifier)
        tableView.register(UINib(nibName: String(describing: ProfileEditTableViewCell.self), bundle: nil), forCellReuseIdentifier: statics.textFieldCellIdentifier)
        tableView.register(UINib(nibName: String(describing: RefundTextTableViewCell.self), bundle: nil), forCellReuseIdentifier: statics.textViewCellIdentifier)
        tableView.tableFooterView = UIView(frame: .zero)

        NotificationCenter.default.addObserver(self, selector: #selector(RefundRequestViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RefundRequestViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: - Control Actions

    @objc func submit(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Notification Handlers

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

// MARK: - <UITableViewDataSource>

extension RefundRequestViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return RefundRequestTableViewSection.count.rawValue
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch RefundRequestTableViewSection(section) {
        case .beneficiary: return statics.beneficiaries.count
        case .benefit: return 3
        case .amount: return 1
        case .images: return 2
        case .notes: return 1
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch RefundRequestTableViewSection(indexPath.section) {
        case .beneficiary:
            let cell = tableView.dequeueReusableCell(withIdentifier: statics.defaultCellIdentifier, for: indexPath) as! RefundRequestTableViewCell
            cell.titleLabel.text = statics.beneficiaries[indexPath.row]
            cell.accessoryType = indexPath.row == 1 ? .checkmark : .none
            return cell
        case .benefit:
            let cell = tableView.dequeueReusableCell(withIdentifier: statics.defaultCellIdentifier, for: indexPath) as! RefundRequestTableViewCell
            cell.titleLabel.text = "Prestación \(indexPath.row + 1)"
            cell.accessoryType = indexPath.row == 2 ? .checkmark : .none
            return cell

        case .amount:
            let cell = tableView.dequeueReusableCell(withIdentifier: statics.textFieldCellIdentifier, for: indexPath) as! ProfileEditTableViewCell
            cell.titleLabel.text = "Monto"
            cell.textField = amountTextField
            cell.isEditable = true
            return cell

        case .images:
            let cell = tableView.dequeueReusableCell(withIdentifier: statics.defaultCellIdentifier, for: indexPath) as! RefundRequestTableViewCell
            cell.titleLabel.text = indexPath.row == 0 ? "Imagen Bono" : "Imagen Orden Examen"
            cell.actionText = "Seleccionar…"
            return cell

        case .notes:
            let cell = tableView.dequeueReusableCell(withIdentifier: statics.textViewCellIdentifier, for: indexPath) as! RefundTextTableViewCell
            cell.textView = textView
            return cell

        default: return UITableViewCell(style: .default, reuseIdentifier: nil)
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return RefundRequestTableViewSection(section).title
    }
}

extension RefundRequestViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return RefundRequestTableViewSection(indexPath.section) == .notes ? 78 : tableView.rowHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
