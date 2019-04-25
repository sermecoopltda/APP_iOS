//
//  DocumentViewController.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/24/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit
import QuickLook

class DocumentViewController: QLPreviewController {
    var document: TransactionDocumentModel?

    fileprivate var tempURL: URL? {
        didSet {
            NSLog("didSet tempURL: \(String(describing: tempURL))")
            document?.previewItemURL = tempURL
        }
    }

    fileprivate let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.color = .darkGray
        activityIndicator.hidesWhenStopped = true
        activityIndicator.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleRightMargin]
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)

        dataSource = self
        delegate = self

        guard let documentURL = document?.url else {
            return
        }

        if let data = AssetsClient.shared.data(forURL: documentURL) {
            // cached data returned
            NSLog("returning cached document data")
            saveToTemporaryURL(data: data, filename: documentURL.lastPathComponent)
        } else {
            NSLog("fetching document data")
            activityIndicator.startAnimating()
            AssetsClient.shared.fetch(URL: documentURL, completionHandler: {
                (data: Data?) in
                if let data = data {
                    self.saveToTemporaryURL(data: data, filename: documentURL.lastPathComponent)
                }
                self.activityIndicator.stopAnimating()
            })
        }

    }

    private func saveToTemporaryURL(data: Data, filename: String) {
        NSLog("saving data to temporary URL")
        guard let documentsURL = try? FileManager.default.url(for: .documentDirectory,
                                                              in: .userDomainMask,
                                                              appropriateFor: nil,
                                                              create: true)
            else {
                NSLog("documentsURL failed")
                return
        }
        let temporaryFileURL = documentsURL.appendingPathComponent(filename)
        do {
            try data.write(to: temporaryFileURL)
            tempURL = temporaryFileURL
            reloadData()
        } catch {
            NSLog("data.write error: \(error.localizedDescription)")
        }
    }
}

// MARK: - <QLPreviewControllerDataSource> Methods

extension DocumentViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return tempURL == nil ? 0 : 1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return document!
    }
}

// MARK: - <QLPreviewControllerDelegate> Methods

extension DocumentViewController: QLPreviewControllerDelegate {
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        guard let tempURL = tempURL else { return }
        try? FileManager.default.removeItem(at: tempURL)
    }
}
