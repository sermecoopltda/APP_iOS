//
//  SplashViewController.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/7/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)

    var loginHandler: ((Bool) -> ())?

    override func loadView() {
        let nib = UINib(nibName: String(describing: SplashViewController.self), bundle: nil)
        view = (nib.instantiate(withOwner: self, options: nil).first as! UIView)

        activityIndicator.color = .darkGray
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let username = SessionModel.current?.username, let password = SessionModel.current?.password else {
            loginHandler?(false)
            return
        }
        activityIndicator.startAnimating()
        APIClient.shared.login(username: username, password: password, completionHandler: {
            (success: Bool, message: String?) in
            self.loginHandler?(success)
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        activityIndicator.sizeToFit()
        activityIndicator.center = CGPoint(x: view.bounds.size.width / 2, y: view.bounds.size.height - 40 - (activityIndicator.bounds.size.height / 2))
    }
}
