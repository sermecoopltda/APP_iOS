//
//  FetchOperation.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/14/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import Foundation

public class FetchOperation: Operation {
    let session: URLSession
    let request: URLRequest
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

    init(session aSession: URLSession, request aRequest: URLRequest) {
        session = aSession
        request = aRequest
        super.init()
    }

    override public func main() {
        isExecuting = true
        isFinished = false

        let dataTask = session.dataTask(with: request,
                                        completionHandler: {
                                            (data: Data?, response: URLResponse?, error: Error?) in
                                            self.completionHandler?(data, response as? HTTPURLResponse, error)
                                            self.isExecuting = false
                                            self.isFinished = true
        })
        dataTask.resume()
    }
}
