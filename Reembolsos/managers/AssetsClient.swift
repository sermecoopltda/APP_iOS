//
//  AssetsClient.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/14/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

public class AssetsClient {
    private struct statics {
        static let memoryCapacity = 4 * 1024 * 1024 // 4 Mb
        static let diskCapacity = 80 * 1024 * 1024 // 80 Mb
        static let diskPath = "thumbsCache"
        static let requestTimeout = TimeInterval(10.0)
    }

    private let operationQueue = OperationQueue()
    public static let shared = AssetsClient()
    private let sessionConfiguration = URLSessionConfiguration.default
    private let session: URLSession
    private let cache = URLCache(memoryCapacity: statics.memoryCapacity, diskCapacity: statics.diskCapacity, diskPath: statics.diskPath)
    private let calendar = Calendar.current

    private init() {
        sessionConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData
        sessionConfiguration.urlCache = nil

        session = URLSession(configuration: sessionConfiguration)
        operationQueue.maxConcurrentOperationCount = 4
    }

    public func data(forURL URL: URL) -> Data? {
        let request = URLRequest(url: URL, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: statics.requestTimeout)
        return cache.cachedResponse(for: request)?.data
    }

    public func image(dataForURL URL: URL) -> UIImage? {
        guard let imageData = data(forURL: URL) else {
            return nil
        }
        return UIImage(data: imageData)
    }

    public func fetch(URL: URL, completionHandler: ((_: Data?) -> ())?) {
        let request = URLRequest(url: URL, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: statics.requestTimeout)
        if let cachedResponse = cache.cachedResponse(for: request), let response = cachedResponse.response as? HTTPURLResponse, response.statusCode == 200, let data = cache.cachedResponse(for: request)?.data {
            // we return the cached data
            if let completionHandler = completionHandler {
                DispatchQueue.main.async(execute: {
                    completionHandler(data)
                })
            }
            return
        }

        let operation = FetchOperation(session: session, request: request)
        operation.completionHandler = {
            (data: Data?, response: HTTPURLResponse?, error: Error?) -> Void in
            DispatchQueue.main.async(execute: {
                if let data = data, let response = response, response.statusCode == 200, error == nil {
                    let cachedResponse = CachedURLResponse(response: response, data: data)
                    self.cache.storeCachedResponse(cachedResponse, for: request)
                    // we return the retrieved data
                    completionHandler?(data)
                } else {
                    completionHandler?(nil)
                }
            })
        }
        operationQueue.addOperation(operation)
    }
}
