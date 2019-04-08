//
//  HTTPClient.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/14/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import Foundation

public typealias HTTPClientParameters = [String: Any]
public typealias HTTPClientResponseJSON = [String: Any]
public typealias HTTPClientCompletionHandler = (Bool, HTTPURLResponse?, Any?) -> ()

public enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case DELETE = "DELETE"
    case PUT = "PUT"
}

public enum HTTPContentType {
    case json
    case formURLEncoded
    case plainText

    var headerValue: String {
        switch self {
        case .json: return "application/json"
        case .formURLEncoded: return "application/x-www-form-urlencoded"
        case .plainText: return "text/plain"
        }
    }

    func HTTPBodyForParameters(_ parameters: HTTPClientParameters) -> Data? {
        switch self {
        case .json:
            do {
                let data = try JSONSerialization.data(withJSONObject: parameters, options: [])
                return data
            } catch {
                NSLog("JSON serialization error: \(error)")
                return nil
            }

        case .formURLEncoded, .plainText:
            var URLComponents = Foundation.URLComponents()
            URLComponents.queryItems = parameters.map {
                (key, value) in
                URLQueryItem(name: key, value: value as? String ?? String(describing: value))
            }
            let data = URLComponents.query?.data(using: String.Encoding.ascii)
            return data
        }
    }
}

open class HTTPClient {
    fileprivate let sessionConfiguration = URLSessionConfiguration.ephemeral
    fileprivate var session: URLSession?

    private let operationQueue = OperationQueue()

    public var httpHeaders: [AnyHashable: Any]? { return nil }

    required public init() {
        sessionConfiguration.urlCache = nil
        // set additonal http headers (eg. app name and version)
        sessionConfiguration.httpAdditionalHeaders = httpHeaders
        sessionConfiguration.httpCookieAcceptPolicy = .always
        session = URLSession(configuration: sessionConfiguration)
        operationQueue.maxConcurrentOperationCount = 4
    }

    // MARK: - Private Helper Methods

    fileprivate func request(URL: Foundation.URL, method: HTTPMethod, contentType: HTTPContentType = .json, parameters: HTTPClientParameters? = nil, headers: [String: String]? = nil) -> URLRequest {
        var request = URLRequest(url: URL)
        request.httpMethod = method.rawValue
        if let parameters = parameters {
            switch method {
            case .GET:
                guard var URLComponents = URLComponents(url: URL, resolvingAgainstBaseURL: true) else {
                    break
                }
                URLComponents.queryItems = parameters.map {
                    (key, value) in
                    URLQueryItem(name: key, value: value as? String ?? String(describing: value))
                }
                if let actualURL = URLComponents.url {
                    request.url = actualURL
                }
                break

            case .POST, .DELETE, .PUT:
                request.setValue(contentType.headerValue, forHTTPHeaderField: "Content-Type")
                request.httpBody = contentType.HTTPBodyForParameters(parameters)
                break
            }
        }
        if let headers = headers {
            for(field, value) in headers {
                request.addValue(value, forHTTPHeaderField: field)
            }
        }

        return request
    }

    // MARK: - Generic Call Methods

    public func performCall(URL: Foundation.URL, method: HTTPMethod, contentType: HTTPContentType = .json, parameters: HTTPClientParameters? = nil, headers: [String: String]? = nil, completionHandler: @escaping HTTPClientCompletionHandler) {
        guard let session = session else {
            completionHandler(false, nil, nil)
            return 
        }
        let request = self.request(URL: URL, method: method, contentType: contentType, parameters: parameters, headers: headers)
        let operation = FetchOperation(session: session, request: request)
        operation.completionHandler = {
            (data: Data?, response: HTTPURLResponse?, error: Error?) in
            DispatchQueue.main.async(execute: {
                if let data = data, error == nil {
                    if let contentType = response?.allHeaderFields["Content-Type"] as? String, contentType.localizedLowercase.hasPrefix(HTTPContentType.plainText.headerValue.localizedLowercase) {
                        // we are plain text
                        let string = String(data: data, encoding: .utf8)
                        completionHandler(string != nil, response, string)
                    } else {
                        // we are json encoded (hopefully)
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: []) // as? APIClientResponseJSON
                            // we are either a JSON root object or an array
                            if json is HTTPClientResponseJSON || json is [HTTPClientResponseJSON] {
                                completionHandler(true, response, json)
                            } else {
                                completionHandler(false, response, nil)
                            }
                        } catch let JSONError as NSError {
                            let responseString = String(data: data, encoding: .utf8)
                            NSLog("JSON Deserialization error: \(JSONError); response: \(String(describing: responseString))")
                            completionHandler(false, response, nil)
                        }
                    }
                } else {
                    NSLog("error: \(String(describing: error))")
                    completionHandler(false, response, nil)
                }
            })
        }
        operationQueue.addOperation(operation)
    }
}
