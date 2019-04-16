//
//  UploadOperation.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/16/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import Foundation

public class UploadOperation: Operation {
    let session: URLSession
    let request: URLRequest
    let data: Data
    var completionHandler: ((_: Data?, _: HTTPURLResponse?, _: Error?) -> ())?

    private var _executing = false
    private var _finished = false

    override public var isExecuting: Bool {
        get { return _executing }
        set {
            if newValue != _executing {
                willChangeValue(forKey: "isExecuting")
                _executing = newValue
                didChangeValue(forKey: "isExecuting")
            }
        }
    }

    override public var isFinished: Bool {
        get { return _finished }
        set {
            if newValue != _finished {
                willChangeValue(forKey: "isFinished")
                _finished = newValue
                didChangeValue(forKey: "isFinished")
            }
        }
    }

    init(session aSession: URLSession, request aRequest: URLRequest, data someData: Data) {
        session = aSession
        request = aRequest
        data = someData
        super.init()
    }

    override public func main() {
        isExecuting = true
        isFinished = false

        let uploadTask = session.uploadTask(with: request,
                                            from: data,
                                            completionHandler: {
                                                (data: Data?, response: URLResponse?, error: Error?) in
                                                self.completionHandler?(data, response as? HTTPURLResponse, error)
                                                self.isExecuting = false
                                                self.isFinished = true

        })
        uploadTask.resume()
    }
}
