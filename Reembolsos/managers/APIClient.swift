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
        }
        performCall(URL: endpointURL, method: method, contentType: contentType, parameters: parameters, headers: newHeaders, completionHandler: completionHandler)
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
}
