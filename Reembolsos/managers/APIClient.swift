//
//  APIClient.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/14/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import Foundation
import Unbox

public class APIClient: HTTPClient {
    public static let shared = APIClient()
    private let baseURL = URL(string: "https://sucursalvirtual.sermecoop.cl/PortalSermecoop/apiRest_desa/")!

    private func performCall(authenticated: Bool = false, method: HTTPMethod, path: String, contentType: HTTPContentType = .json, parameters: HTTPClientParameters? = nil, headers: [String: String]? = nil, completionHandler: @escaping HTTPClientCompletionHandler) {
        guard let endpointURL = URL(string: path, relativeTo: baseURL) else {
            completionHandler(false, nil, nil)
            return
        }
        var newHeaders: [String: String] = [:]
        if let headers = headers {
            for key in headers.keys {
                newHeaders[key] = headers[key]
            }
        }
        if authenticated {
            guard let currentUser = SessionModel.current else {
                NSLog("not currentUser")
                completionHandler(false, nil, nil)
                return
            }
            newHeaders["Authorization"] = currentUser.token

            NSLog("** endpoint: \(endpointURL.absoluteString); Authorization: \(currentUser.token)")
        }
        performCall(URL: endpointURL, method: method, contentType: contentType, parameters: parameters, headers: newHeaders, completionHandler: completionHandler)
    }

    private func performUpload(authenticated: Bool = false, method: HTTPMethod, path: String, data: Data, headers: [String: String]? = nil, completionHandler: @escaping HTTPClientCompletionHandler) {
        guard let endpointURL = URL(string: path, relativeTo: baseURL) else {
            completionHandler(false, nil, nil)
            return
        }
        var newHeaders: [String: String] = [:]
        if let headers = headers {
            for key in headers.keys {
                newHeaders[key] = headers[key]
            }
        }
        if authenticated {
            guard let currentUser = SessionModel.current else {
                NSLog("not currentUser")
                completionHandler(false, nil, nil)
                return
            }
            newHeaders["Authorization"] = currentUser.token
        }
        performUpload(URL: endpointURL, data: data, method: method, headers: newHeaders, completionHandler: completionHandler)
    }

    // MARK: - Public Methods

    public func login(username: String, password: String, completionHandler: ((Bool, String?) -> ())?) {
        let path = "login.php"
        let parameters: HTTPClientParameters = ["username": username, "password": password]

        performCall(method: .POST,
                    path: path,
                    parameters: parameters,
                    completionHandler: {
                        (success: Bool, response: HTTPURLResponse?, json: Any?) in
                        let json = json as? HTTPClientResponseJSON
                        if success, let response = response, let token = json?["auth_token"] as? String {
                            switch response.statusCode {
                            case 200:
                                SessionModel.setCurrent(token: token, username: username, password: password)
                                completionHandler?(true, json?["msg"] as? String)

                            default:
                                completionHandler?(false, json?["msg"] as? String)
                            }
                        } else {
                            completionHandler?(false, nil)
                        }
        })
    }

    public func benefitRules(completionHandler: ((Bool, BenefitRulesModel?) -> ())?) {
        let path = "reglasPrestaciones.php"

        performCall(authenticated: true,
                    method: .GET,
                    path: path,
                    completionHandler: {
                        (success: Bool, response: HTTPURLResponse?, json: Any?) in
                        if success, let json = json as? HTTPClientResponseJSON {
                            do {
                                let benefitRules: BenefitRulesModel = try unbox(dictionary: json)
                                completionHandler?(true, benefitRules)
                            } catch let error {
                                NSLog("benefitRules API call failed; unbox error: \(error)")
                            }
                        } else {
                            NSLog("benefitRules API call failed")
                            completionHandler?(false, nil)
                        }
        })
    }

    public func profile(completionHandler: ((Bool, UserModel?) -> ())?) {
        let path = "obtenerPerfil.php"

        performCall(authenticated: true,
                    method: .GET,
                    path: path,
                    completionHandler: {
                        (success: Bool, response: HTTPURLResponse?, json: Any?) in
                        if success, let json = json as? HTTPClientResponseJSON {
                            do {
                                let user: UserModel = try unbox(dictionary: json)
                                completionHandler?(true, user)
                            } catch let error {
                                NSLog("profile API call failed; error: \(error)")
                                completionHandler?(false, nil)
                            }
                        } else {
                            NSLog("profile API call failed")
                            completionHandler?(false, nil)
                        }
        })
    }

    public func updateProfile(name: String?, phoneNumber: String?, email: String?, completionHandler: ((Bool) -> ())?) {
        let path = "modificarPerfil.php"
        var parameters: HTTPClientParameters = [:]
        if let name = name {
            parameters["nombre"] = name
        }
        if let phoneNumber = phoneNumber {
            parameters["telefono"] = phoneNumber
        }
        if let email = email {
            parameters["email"] = email
        }

        if parameters.count == 0 {
            completionHandler?(true)
            return
        }

        performCall(authenticated: true,
                    method: .POST,
                    path: path,
                    parameters: parameters,
                    completionHandler: {
                        (success: Bool, response: HTTPURLResponse?, json: Any?) in
                        if success, let response = response, response.statusCode == 200 {
                            completionHandler?(true)
                        } else {
                            NSLog("updateProfile API call failed")
                            completionHandler?(false)
                        }
        })
    }

    public func requestRefund(amount: Int, beneficiary: String, benefit: Int, notes: String, completionHandler: ((Bool, String?) -> ())?) {
        let path = "nuevoReembolso.php"
        let parameters: HTTPClientParameters = [
            "beneficiario": beneficiary,
            "tipo_prestacion": benefit,
            "monto": amount,
            "observaciones": notes
        ]

        performCall(authenticated: true,
                    method: .POST,
                    path: path,
                    parameters: parameters,
                    completionHandler: {
                        (success: Bool, response: HTTPURLResponse?, json: Any?) in
                        if success, let json = json as? HTTPClientResponseJSON, let identifier = json["folio"] as? String {
                            completionHandler?(true, identifier)
                        } else {
                            NSLog("requestRefund API call failed")
                            completionHandler?(false, nil)
                        }
        })
    }

    public func uploadPicture(data: Data, identifier: String, documentCode: Int, completionHandler: ((Bool, URL?) -> ())?) {
        let path = "upload.php"
        let headers: [String: String] = [
            "folio": identifier,
            "tipoDoc": String(documentCode)
        ]

        performUpload(authenticated: true,
                      method: .PUT,
                      path: path,
                      data: data,
                      headers: headers, completionHandler: {
                        (success: Bool, response: HTTPURLResponse?, json: Any?) in
                        NSLog("performUpload returned; json: \(String(describing: json))")
                        if success, let json = json as? HTTPClientResponseJSON, let uploadedURL = json["url"] as? String {
                            completionHandler?(true, URL(string: uploadedURL))
                        } else {
                            NSLog("uploadPicture API call failed")
                            completionHandler?(false, nil)
                        }
        })
    }

    public func tracking(month: Int, year: Int, completionHandler: ((Bool, [TransactionModel]) -> ())?) {
        let path = "reembolsos.php"

        let calendar = Calendar.current
        let fromComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current, year: year, month: month, day: 1)
        let toComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current, year: year, month: month + 1, day: 0)
        guard let fromDate = calendar.date(from: fromComponents), let toDate = calendar.date(from: toComponents) else {
            completionHandler?(false, [])
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let parameters: HTTPClientParameters = [
            "desde": dateFormatter.string(from: fromDate),
            "hasta": dateFormatter.string(from: toDate)
        ]

        performCall(authenticated: true,
                    method: .GET,
                    path: path,
                    parameters: parameters,
                    completionHandler: {
                        (success: Bool, response: HTTPURLResponse?, json: Any?) in
                        if success, let json = json as? [HTTPClientResponseJSON] {
                            do {
                                let trackingEvents: [TransactionModel] = try unbox(dictionaries: json)
                                completionHandler?(true, trackingEvents)
                            } catch let error {
                                NSLog("tracking(month, year) API call failed; unbox error: \(error)")
                                completionHandler?(false, [])
                            }
                        } else {
                            NSLog("tracking(month, year) API call failed")
                            completionHandler?(false, [])
                        }
            })
    }

    public func tracking(identifier: String, completionHandler: ((Bool, [TransactionModel]) -> ())?) {
        let path = "reembolsos.php"
        let parameters: HTTPClientParameters = ["folio": identifier]

        performCall(authenticated: true,
                    method: .GET,
                    path: path,
                    parameters: parameters,
                    completionHandler: {
                        (success: Bool, response: HTTPURLResponse?, json: Any?) in
                        if success, let json = json as? [HTTPClientResponseJSON] {
                            do {
                                let trackingEvents: [TransactionModel] = try unbox(dictionaries: json)
                                completionHandler?(true, trackingEvents)
                            } catch let error {
                                NSLog("tracking(month, year) API call failed; unbox error: \(error)")
                                completionHandler?(false, [])
                            }
                        } else {
                            NSLog("tracking(month, year) API call failed")
                            completionHandler?(false, [])
                        }
        })
    }

    public func transaction(identifier: String, completionHandler: ((Bool, TransactionDetailModel?) -> ())?) {
        let path = "consultaDetalleReembolso.php"
        let parameters: HTTPClientParameters = ["folio": identifier]

        performCall(authenticated: true,
                    method: .GET,
                    path: path,
                    parameters: parameters,
                    completionHandler: {
                        (success: Bool, response: HTTPURLResponse?, json: Any?) in
                        if success, let json = json as? HTTPClientResponseJSON {
                            do {
                                let transaction: TransactionDetailModel = try unbox(dictionary: json)
                                completionHandler?(true, transaction)
                            } catch let error {
                                NSLog("transaction(identifier) API call failed; unbox error: \(error)")
                                completionHandler?(false, nil)
                            }
                        } else {
                            NSLog("transaction(identifier) API call failed")
                            completionHandler?(false, nil)
                        }
        })
    }

    public func history(month: Int, year: Int, completionHandler: ((Bool) -> ())?) {
        let path = "historicoReembolsos.php"

        let calendar = Calendar.current
        let fromComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current, year: year, month: month, day: 1)
        let toComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current, year: year, month: month + 1, day: 0)
        guard let fromDate = calendar.date(from: fromComponents), let toDate = calendar.date(from: toComponents) else {
            completionHandler?(false)
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let parameters: HTTPClientParameters = [
            "desde": dateFormatter.string(from: fromDate),
            "hasta": dateFormatter.string(from: toDate)
        ]

        performCall(authenticated: true,
                    method: .GET,
                    path: path,
                    parameters: parameters,
                    completionHandler: {
                        (success: Bool, response: HTTPURLResponse?, json: Any?) in
                        NSLog("history API call success: \(success); json: \(String(describing: json))")
                        completionHandler?(success)
//                        if success, let json = json as? [HTTPClientResponseJSON] {
//                            do {
//                                let trackingEvents: [TransactionModel] = try unbox(dictionaries: json)
//                                completionHandler?(true, trackingEvents)
//                            } catch let error {
//                                NSLog("tracking(month, year) API call failed; unbox error: \(error)")
//                                completionHandler?(false, [])
//                            }
//                        } else {
//                            NSLog("tracking(month, year) API call failed")
//                            completionHandler?(false, [])
//                        }
        })
    }


}
