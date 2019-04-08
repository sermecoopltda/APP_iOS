//
//  RefundTermsViewController.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/19/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit
import WebKit

class RefundTermsViewController: UIViewController {
    private var webView: WKWebView!
    private let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Términos de Uso"
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: view.bounds, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)

        activityIndicator.color = .darkGray
        activityIndicator.hidesWhenStopped = true
        activityIndicator.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]
        activityIndicator.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        view.addSubview(activityIndicator)

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(RefundTermsViewController.cancel(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Aceptar", style: .done, target: self, action: #selector(RefundTermsViewController.accept(_:)))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        guard
            let htmlURL = Bundle.main.url(forResource: "refund_terms", withExtension: "html"),
            let htmlData = try? Data(contentsOf: htmlURL),
            let htmlString = String(data: htmlData, encoding: .utf8)
        else { return }
        activityIndicator.startAnimating()
        APIClient.shared.benefitRules(completionHandler: {
            (success: Bool, benefitRules: BenefitRulesModel?) in
            if success, let benefitRules = benefitRules {
                let rulesHTML = benefitRules.policyParagraphs.map {
                    return "<li>\($0)</li>\n"
                }
                self.webView.loadHTMLString(
                    htmlString
                        .replacingOccurrences(of: "%%RULES_HTML_CONTENTS%%", with: rulesHTML.joined(separator: "\n"))
                        .replacingOccurrences(of: "%%TERMS_URL%%", with: benefitRules.termsURL.absoluteString)
                    , baseURL: nil)
            } else {
                self.activityIndicator.stopAnimating()
                let controller = UIAlertController(title: "Error Obteniendo Datos",
                                                   message: "Ocurrió un error al intentar obtener los datos de prestaciones. Por favor revisa los ajustes de tu conexión de red e intenta nuevamente.",
                                                   preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Aceptar", style: .default, handler: {
                    _ in
                    self.dismiss(animated: true, completion: nil)
                })
                controller.addAction(okAction)
                self.present(controller, animated: true, completion: nil)
            }
        })
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        webView.frame.size.height = view.safeAreaLayoutGuide.layoutFrame.size.height
    }

    @objc func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @objc func accept(_ sender: Any) {
        let controller = RefundProfileEditViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - <WKNavigationDelegate> Methods

extension RefundTermsViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard navigationAction.navigationType == .linkActivated, let linkURL = navigationAction.request.url, UIApplication.shared.canOpenURL(linkURL) else {
            decisionHandler(.allow)
            return
        }
        UIApplication.shared.open(linkURL, options: [:], completionHandler: nil)
        decisionHandler(.cancel)
    }
}
