//
//  LoginViewController.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/13/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var usernameField: CustomTextField!
    @IBOutlet var passwordField: CustomTextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var forgotPasswordButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    private var isEnabledLoginButton = false {
        didSet {
            loginButton.isEnabled = isEnabledLoginButton
            loginButton.layer.borderColor = isEnabledLoginButton ? UIColor.white.cgColor : UIColor(hex: "#588dcf").cgColor
            loginButton.alpha = isEnabledLoginButton ? 1 : 0.8
        }
    }


    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.textDidChange(_:)), name: UITextField.textDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        loginButton.layer.cornerRadius = loginButton.bounds.size.height / 2
        loginButton.layer.borderWidth = 2
        loginButton.layer.masksToBounds = true

        usernameField.leftImage = #imageLiteral(resourceName: "login-icon-username")
        passwordField.leftImage = #imageLiteral(resourceName: "login-icon-password")

        forgotPasswordButton.titleLabel?.textAlignment = .center

        conditionallyEnableLoginButton()

        // usernameField.becomeFirstResponder()

        guard let font = forgotPasswordButton.titleLabel?.font, let color = forgotPasswordButton.titleColor(for: .normal), let title = forgotPasswordButton.title(for: .normal) else { return }
        var attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        let attributedString = NSAttributedString(string: title, attributes: attributes)
        forgotPasswordButton.setAttributedTitle(attributedString, for: .normal)
    }

    private func conditionallyEnableLoginButton() {
        guard let text = usernameField.text, text != "" else {
            isEnabledLoginButton = false
            return
        }
        isEnabledLoginButton = true
    }

    @IBAction func loginButtonTouched(_ sender: Any) {
        view.endEditing(true)
        guard let username = usernameField.text, let password = passwordField.text else { return }
        activityIndicator.startAnimating()
        scrollView.isUserInteractionEnabled = false
        APIClient.shared.login(username: username, password: password, completionHandler: {
            (success: Bool, message: String?) in
            self.activityIndicator.stopAnimating()
            self.scrollView.isUserInteractionEnabled = true
            if success {
                appDelegate.switchToTabBarController(animated: true)
            } else {
                let controller = UIAlertController(title: "Error al Iniciar Sesión",
                                                   message: "El RUT o la contraseña especificados son incorrectos. Por favor revisa tus datos e intenta nuevamente.",
                                                   preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
                controller.addAction(dismissAction)
                self.present(controller, animated: true, completion: nil)
            }
        })
    }

    @IBAction func forgotPasswordButtonTouched(_ sender: Any) {
        let controller = UIAlertController(title: "Recuperar Contraseña",
                                           message: "Si deseas crear o recuperar tu contraseña debes comunicarte con nuestro Call Center llamando al 600 655 8000", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        let callURL = URL(string: "tel:6006558000")!
        if UIApplication.shared.canOpenURL(callURL) {
            let callAction = UIAlertAction(title: "Llamar", style: .default, handler: {
                (action: UIAlertAction) in
                UIApplication.shared.open(callURL, options: [:], completionHandler: nil)
            })
            controller.addAction(callAction)
            controller.preferredAction = callAction
        }
        present(controller, animated: true, completion: nil)
    }

    // MARK: - Notification Handlers

    @objc func textDidChange(_ notification: Notification) {
        self.conditionallyEnableLoginButton()
    }

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
                        self.scrollView.contentInset.bottom = keyboardFrame.size.height
                        self.scrollView.scrollIndicatorInsets.bottom = keyboardFrame.size.height
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
                        self.scrollView.contentInset.bottom = 0
                        self.scrollView.scrollIndicatorInsets.bottom = 0
        },
                       completion: nil)
    }
}

// MARK: - <UITextFieldDelegate> Methods

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            passwordField.becomeFirstResponder()
        } else {
            loginButtonTouched(loginButton)
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField == usernameField, let username = textField.text?.localizedUppercase, username.count > 1 else { return }
        let allowedCharacters = "1234567890K"
        var unformattedUsername = username.filter(allowedCharacters.contains)
        let lastCharacter = unformattedUsername.popLast()!
        let formattedUsername = String(String(unformattedUsername.reversed()).inserting(separator: ".", every: 3).reversed())
        usernameField.text = "\(formattedUsername)-\(lastCharacter)"
    }
}
