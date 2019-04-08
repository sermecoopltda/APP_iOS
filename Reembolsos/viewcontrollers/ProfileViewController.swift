//
//  ProfileViewController.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/14/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    convenience init() {
        self.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: "Mi Perfil", image: #imageLiteral(resourceName: "tabBar-profile"), tag: 2)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
