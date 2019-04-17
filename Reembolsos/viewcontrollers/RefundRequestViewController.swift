//
//  RefundRequestViewController.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/19/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit
import MobileCoreServices

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
        static let documentCellIdentifier = "documentCellIdentifier"
        static let beneficiaries = ["Juan Pérez", "María González"]
    }

    @IBOutlet var tableView: UITableView!
    @IBOutlet var amountTextField: UITextField!
    @IBOutlet var notesTextView: UITextView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    fileprivate var submitButtonItem: UIBarButtonItem {
        return UIBarButtonItem(title: "Enviar", style: .done, target: self, action: #selector(RefundRequestViewController.submit(_:)))
    }

    var benefitRules: BenefitRulesModel?
    var user: UserModel?

    var selectedBeneficiaryIndex: Int = 0 {
        didSet {
            if !isViewLoaded { return }
            let section = RefundRequestTableViewSection.beneficiary.rawValue
            let numberOfRows = tableView.numberOfRows(inSection: section)
            if oldValue < numberOfRows {
                let oldIndexPath = IndexPath(row: oldValue, section: section)
                let oldCell = tableView.cellForRow(at: oldIndexPath)
                oldCell?.accessoryType = .none
            }
            if selectedBeneficiaryIndex < numberOfRows {
                let indexPath = IndexPath(row: selectedBeneficiaryIndex, section: section)
                let cell = tableView.cellForRow(at: indexPath)
                cell?.accessoryType = .checkmark
            }
        }
    }
    var selectedBenefitIndex: Int = 0 {
        didSet {
            if !isViewLoaded { return }
            let section = RefundRequestTableViewSection.benefit.rawValue
            let numberOfRows = tableView.numberOfRows(inSection: section)
            if oldValue < numberOfRows {
                let oldIndexPath = IndexPath(row: oldValue, section: section)
                let oldCell = tableView.cellForRow(at: oldIndexPath)
                oldCell?.accessoryType = .none
            }
            if selectedBenefitIndex < numberOfRows {
                let indexPath = IndexPath(row: selectedBenefitIndex, section: section)
                let cell = tableView.cellForRow(at: indexPath)
                cell?.accessoryType = .checkmark
            }
            selectedDocuments = [:]
            amountTextField.text = nil
            let imageSection = RefundRequestTableViewSection.images.rawValue
            let sections = IndexSet(integer: imageSection)
            tableView.reloadSections(sections, with: .none)
            guard let benefits = benefitRules?.benefits else { return }
            let benefit = benefits[selectedBenefitIndex]
            amountTextField.placeholder = "Máximo $\(PriceFormatter.string(from: benefit.maxAmount))"

        }
    }
    var selectedDocumentIndex: Int = 0

    var selectedDocuments: [Int: UIImage] = [:] {
        didSet {
            conditionallyEnableSubmitButton()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Nuevo Reembolso"
        navigationItem.rightBarButtonItem = submitButtonItem

        tableView.register(UINib(nibName: String(describing: RefundRequestTableViewCell.self), bundle: nil), forCellReuseIdentifier: statics.defaultCellIdentifier)
        tableView.register(UINib(nibName: String(describing: ProfileEditTableViewCell.self), bundle: nil), forCellReuseIdentifier: statics.textFieldCellIdentifier)
        tableView.register(UINib(nibName: String(describing: RefundDocumentTableViewCell.self), bundle: nil), forCellReuseIdentifier: statics.documentCellIdentifier)
        tableView.register(UINib(nibName: String(describing: RefundTextTableViewCell.self), bundle: nil), forCellReuseIdentifier: statics.textViewCellIdentifier)
        tableView.tableFooterView = UIView(frame: .zero)

        NotificationCenter.default.addObserver(self, selector: #selector(RefundRequestViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RefundRequestViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RefundRequestViewController.textDidChange(_:)), name: UITextField.textDidChangeNotification, object: nil)

        tableView.isHidden = true
        activityIndicator.startAnimating()
        APIClient.shared.profile(completionHandler: {
            (success: Bool, user: UserModel?) in
            self.activityIndicator.stopAnimating()
            if success, let user = user {
                self.user = user
                self.tableView.isHidden = false
                self.tableView.reloadData()
            } else {
                // display error alert
            }
        })

        conditionallyEnableSubmitButton()

        guard let benefits = benefitRules?.benefits, benefits.count > 0 else { return }
        let benefit = benefits[selectedBenefitIndex]
        amountTextField.placeholder = "Máximo $\(PriceFormatter.string(from: benefit.maxAmount))"
    }

    fileprivate func conditionallyEnableSubmitButton() {
        navigationItem.rightBarButtonItem?.isEnabled = false
        guard let amount = amountTextField.text, amount.count > 0, let benefits = benefitRules?.benefits else { return }
        let documents = benefits[selectedBenefitIndex].documents
        if selectedDocuments.count != documents.count { return }
        navigationItem.rightBarButtonItem?.isEnabled = true
    }

    fileprivate func failWithError(title: String, message: String, completionHandler: (() -> ())? = nil) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }

    fileprivate func uploadNextPicture(index: Int, identifier: String) {
        let keys = Array(selectedDocuments.keys)
        guard index < keys.count, let image = selectedDocuments[keys[index]], let imageData = image.jpegData(compressionQuality: 0.75) else {
            let controller = UIAlertController(title: "Solicitud Completada",
                                               message: "La solicitud de reembolso ha sido enviada exitosamente y será revisada por nuestros ejecutivos. Puedes realizar el seguimiento al estado de tus solicitudes en la pantalla \"Mis Movimientos\".",
                                               preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Aceptar", style: .default, handler: {
                _ in
                self.dismiss(animated: true, completion: nil)
            })
            controller.addAction(okAction)
            present(controller, animated: true, completion: nil)
            return
        }
        APIClient.shared.uploadPicture(data: imageData, identifier: identifier, documentCode: keys[index], completionHandler: {
            (success: Bool, imageURL: URL?) in
            if success, let imageURL = imageURL {
                NSLog("uploadPicture success; imageURL: \(imageURL.absoluteString)")
                self.uploadNextPicture(index: index + 1, identifier: identifier)
            } else {
                NSLog("uploadPicture API call failed")
                self.failWithError(title: "Error Registrando Solicitud",
                                   message: "Ocurrió un error al registrar la solicitud de reembolso. Por favor revisa tus ajustes de red e intenta nuevamente,",
                                   completionHandler: {
                                    self.navigationItem.setHidesBackButton(false, animated: true)
                                    self.navigationItem.rightBarButtonItem = self.submitButtonItem
                                    self.tableView.isUserInteractionEnabled = true
                })
            }
        })



    }

    // MARK: - Control Actions

    @objc func submit(_ sender: Any) {
        view.endEditing(true)
        guard let user = user, let benefits = benefitRules?.benefits, benefits.count > 0, let amount = amountTextField.text else { return }
        let benefit = benefits[selectedBenefitIndex]
        let amountInt = Int(PriceFormatter.number(from: amount))
        guard amountInt > 0 else {
            failWithError(title: "Monto Inválido", message: "El monto ingresado no es válido.", completionHandler: {
                self.amountTextField.becomeFirstResponder()
            })
            return
        }

        if amountInt > benefit.maxAmount {
            failWithError(title: "Monto Inválido", message: "El monto solicitado supera el máximo permitido para el tipo de prestación seleccionada.", completionHandler: {
                self.amountTextField.becomeFirstResponder()
            })
            return
        }

        let beneficiary = selectedBeneficiaryIndex == 0 ? user.rut : user.beneficiaries[selectedBeneficiaryIndex - 1].rut

        tableView.isUserInteractionEnabled = false
        navigationItem.setHidesBackButton(true, animated: true)
        let indicator = UIActivityIndicatorView(style: .white)
        indicator.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicator)
        APIClient.shared.requestRefund(amount: amountInt,
                                       beneficiary: beneficiary,
                                       benefit: benefit.code,
                                       notes: notesTextView.text,
                                       completionHandler: {
                                        (success: Bool, identifier: String?) in
                                        NSLog("refundRequest API success: \(success)")
                                        if success, let identifier = identifier {
                                            self.uploadNextPicture(index: 0, identifier: identifier)
                                        } else {
                                            // error alert
                                            self.failWithError(title: "Error Registrando Solicitud",
                                                               message: "Ocurrió un error al registrar la solicitud de reembolso. Por favor revisa tus ajustes de red e intenta nuevamente,",
                                                               completionHandler: {
                                                                self.navigationItem.setHidesBackButton(false, animated: true)
                                                                self.navigationItem.rightBarButtonItem = self.submitButtonItem
                                                                self.tableView.isUserInteractionEnabled = true
                                            })
                                        }
        })
//        dismiss(animated: true, completion: nil)
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

    @objc func textDidChange(_ notification: Notification) {
        conditionallyEnableSubmitButton()
    }
}

// MARK: - <UITableViewDataSource>

extension RefundRequestViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return RefundRequestTableViewSection.count.rawValue
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch RefundRequestTableViewSection(section) {
        case .beneficiary:
            guard let user = user else { return 0 }
            return user.beneficiaries.count + 1
        case .benefit:
            return benefitRules?.benefits.count ?? 0
        case .amount: return 1
        case .images:
            guard let benefit = benefitRules?.benefits[selectedBenefitIndex] else { return 0 }
            return benefit.documents.count
        case .notes: return 1
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch RefundRequestTableViewSection(indexPath.section) {
        case .beneficiary:
            let cell = tableView.dequeueReusableCell(withIdentifier: statics.defaultCellIdentifier, for: indexPath) as! RefundRequestTableViewCell
            if indexPath.row == 0 {
                cell.titleLabel.text = user?.name
            } else {
                let beneficiary = user?.beneficiaries[indexPath.row - 1]
                cell.titleLabel.text = beneficiary?.name
            }
            cell.accessoryType = selectedBeneficiaryIndex == indexPath.row ? .checkmark : .none
            return cell
        case .benefit:
            let cell = tableView.dequeueReusableCell(withIdentifier: statics.defaultCellIdentifier, for: indexPath) as! RefundRequestTableViewCell
            let benefit = benefitRules?.benefits[indexPath.row]
            cell.titleLabel.text = benefit?.name
            cell.accessoryType = selectedBenefitIndex == indexPath.row ? .checkmark : .none
            return cell

        case .amount:
            let cell = tableView.dequeueReusableCell(withIdentifier: statics.textFieldCellIdentifier, for: indexPath) as! ProfileEditTableViewCell
            cell.titleLabel.text = "Monto"
            cell.textField = amountTextField
            cell.isEditable = true
            return cell

        case .images:
            let cell = tableView.dequeueReusableCell(withIdentifier: statics.documentCellIdentifier, for: indexPath) as! RefundDocumentTableViewCell
            let benefit = benefitRules?.benefits[selectedBenefitIndex]
            let document = benefit?.documents[indexPath.row]
            cell.titleLabel.text = document?.name
            cell.actionText = "Seleccionar…"
            if let documentCode = document?.code {
                cell.documentImage = selectedDocuments[documentCode]
            } else {
                cell.documentImage = nil 
            }
            return cell

        case .notes:
            let cell = tableView.dequeueReusableCell(withIdentifier: statics.textViewCellIdentifier, for: indexPath) as! RefundTextTableViewCell
            cell.textView = notesTextView
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
        switch RefundRequestTableViewSection(indexPath.section) {
        case .notes: return 78
        case .images: return UITableView.automaticDimension
        default: return tableView.rowHeight
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        tableView.deselectRow(at: indexPath, animated: true)
        switch RefundRequestTableViewSection(indexPath.section) {
        case .beneficiary:
            selectedBeneficiaryIndex = indexPath.row

        case .benefit:
            selectedBenefitIndex = indexPath.row

        case .images:
            selectedDocumentIndex = indexPath.row
            let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let cameraAction = UIAlertAction(title: "Tomar Foto desde Cámara", style: .default, handler: {
                    (action: UIAlertAction) in
                    let controller = UIImagePickerController()
                    controller.sourceType = .camera
                    controller.mediaTypes = [kUTTypeImage as String]
                    controller.delegate = self
                    controller.allowsEditing = false // true
                    self.present(controller, animated: true, completion: nil)
                })
                controller.addAction(cameraAction)
                controller.preferredAction = cameraAction
            }

            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
                let libraryAction = UIAlertAction(title: "Seleccionar Foto desde Biblioteca", style: .default, handler: {
                    (action: UIAlertAction) in
                    let controller = UIImagePickerController()
                    controller.sourceType = .savedPhotosAlbum
                    controller.mediaTypes = [kUTTypeImage as String]
                    controller.delegate = self
                    controller.allowsEditing = false // true
                    self.present(controller, animated: true, completion: nil)
                })
                controller.addAction(libraryAction)
            }

            let benefit = benefitRules?.benefits[selectedBenefitIndex]
            let document = benefit?.documents[indexPath.row]
            if let documentCode = document?.code, selectedDocuments[documentCode] != nil {
                let deleteAction = UIAlertAction(title: "Eliminar Imagen", style: .destructive, handler: {
                    _ in
                    self.selectedDocuments[documentCode] = nil
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                })
                controller.addAction(deleteAction)
            }

            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
            controller.addAction(cancelAction)
            present(controller, animated: true, completion: nil)

        case .amount:
            amountTextField.becomeFirstResponder()

        case .notes:
            notesTextView.becomeFirstResponder()

        default: ()
        }
    }
}

// MARK: - <UIImagePickerControllerDelegate> Methods

extension RefundRequestViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            picker.dismiss(animated: true, completion: nil)
        }
        //        guard let mediaType = info[UIImagePickerControllerMediaType] as? String, mediaType == (kUTTypeImage as String), let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage else {
        guard let mediaType = info[.mediaType] as? String, mediaType == (kUTTypeImage as String), let originalImage = info[.originalImage] as? UIImage, let document = benefitRules?.benefits[selectedBenefitIndex].documents[selectedDocumentIndex] else {
            return
        }
        selectedDocuments[document.code] = originalImage // editedImage
        let sections = IndexSet(integer: RefundRequestTableViewSection.images.rawValue)
        tableView.reloadSections(sections, with: .none)
    }
}

// MARK: - <UITextFieldDelegate> Methods

extension RefundRequestViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField == amountTextField, let amountString = textField.text, let amount = Int(amountString) else { return }
        textField.text = PriceFormatter.string(from: amount)
    }
}
