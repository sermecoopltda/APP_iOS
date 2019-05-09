//
//  ProfileEditViewController.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/24/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

class ProfileEditViewController: UIViewController {
    private struct statics {
        static let cellIdentifier = "cellIdentifier"
    }

    @IBOutlet var tableView: UITableView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var phoneTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!

    fileprivate var user: UserModel? {
        didSet {
            if !isViewLoaded { return }
            nameTextField.text = user?.name
            emailTextField.text = user?.email
            phoneTextField.text = user?.phoneNumber

            self.conditionallyEnableDoneButton()
        }
    }

    fileprivate var doneButtonItem: UIBarButtonItem {
        return UIBarButtonItem(title: "Aceptar", style: .done, target: self, action: #selector(ProfileEditViewController.done(_:)))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Actualizar Datos"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ProfileEditViewController.cancel(_:)))
        tableView.register(UINib(nibName: String(describing: ProfileEditTableViewCell.self), bundle: nil), forCellReuseIdentifier: statics.cellIdentifier)

        NotificationCenter.default.addObserver(self, selector: #selector(ProfileEditViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileEditViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileEditViewController.textFieldTextDidChange(_:)), name: UITextField.textDidChangeNotification, object: nil)

        refreshProfile()
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
                self.navigationItem.rightBarButtonItem = self.doneButtonItem
                self.conditionallyEnableDoneButton()
            } else {
                let controller = UIAlertController(title: "Error Obteniendo Datos", message: "Ocurrió un error al obtener los datos del usuario. Por favor revisa tus ajustes de red e intenta nuevamente.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
                controller.addAction(okAction)
                self.present(controller, animated: true, completion: nil)
            }
        })
    }

    fileprivate func conditionallyEnableDoneButton() {
        let textFields: [UITextField] = [nameTextField, phoneTextField, emailTextField]
        for textField in textFields {
            guard let text = textField.text, text.count > 0 else {
                navigationItem.rightBarButtonItem?.isEnabled = false
                return
            }
        }
        navigationItem.rightBarButtonItem?.isEnabled = true
    }

    // MARK: Control Actions

    @objc func done(_ sender: Any) {
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
        navigationItem.leftBarButtonItem?.isEnabled = false
        let activityIndicator = UIActivityIndicatorView(style: .white)
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        APIClient.shared.updateProfile(name: nameTextField.text, phoneNumber: phoneTextField.text, email: emailTextField.text, completionHandler: {
            (success: Bool) in
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            self.tableView.isUserInteractionEnabled = true
            self.navigationItem.rightBarButtonItem = self.doneButtonItem
            self.conditionallyEnableDoneButton()
            if success {
                self.dismiss(animated: true, completion: nil)
            } else {
                let controller = UIAlertController(title: "Error Guardando Datos", message: "Ocurrió un error al almacenar los datos del usuario. Por favor revisa tus ajustes de red e intenta nuevamente.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
                controller.addAction(okAction)
                self.present(controller, animated: true, completion: nil)
            }
        })
    }

    @objc func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
        conditionallyEnableDoneButton()
    }
}

// MARK: - <UITableViewDataSource> Methods

extension ProfileEditViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: statics.cellIdentifier, for: indexPath) as! ProfileEditTableViewCell
        switch indexPath.row {
        case 0:
            cell.titleLabel.text = "Nombre"
            cell.textField = nameTextField
            cell.isEditable = false

        case 1:
            cell.titleLabel.text = "Celular"
            cell.textField = phoneTextField
            cell.isEditable = true

        case 2:
            cell.titleLabel.text = "E-mail"
            cell.textField = emailTextField
            cell.isEditable = true

        default: ()
        }
        return cell
    }
}

// MARK: - <UITableViewDelegate> Methods

extension ProfileEditViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath.row == 0 ? nil : indexPath
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as? ProfileEditTableViewCell
        cell?.textField?.becomeFirstResponder()
    }

}
