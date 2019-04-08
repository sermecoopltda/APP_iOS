//
//  AppDelegate.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/13/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

let appDelegate = UIApplication.shared.delegate as! AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white

        if SessionModel.current != nil {
            let controller = SplashViewController()
            controller.loginHandler = {
                (success: Bool) in
                if success {
                    self.switchToTabBarController(animated: true)
                } else {
                    SessionModel.signOut()
                    self.switchToLoginViewController(animated: false)
                }
            }
            window?.rootViewController = controller
        } else {
            window?.rootViewController = LoginViewController()
        }
        window?.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    @objc func signOutButtonTouched(_ sender: Any) {
        let controller = UIAlertController(title: "Cerrar Sesión", message: "¿Estás seguro que deseas cerrar sesión?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Cerrar Sesión", style: .destructive, handler: {
            _ in
            SessionModel.signOut()
            self.switchToLoginViewController(animated: true)
        })
        controller.addAction(cancelAction)
        controller.addAction(confirmAction)
        controller.preferredAction = cancelAction
        window?.rootViewController?.present(controller, animated: true, completion: nil)
    }

    func switchToTabBarController(animated: Bool) {
        let transactionsViewController = SegmentedViewController()
        transactionsViewController.viewControllers = [TransactionsTrackingViewController(), TransactionsHistoryViewController()]
        transactionsViewController.tabBarItem = UITabBarItem(title: "Mis Movimientos", image: #imageLiteral(resourceName: "tabBar-transactions"), tag: 1)

        let viewControllers = [RefundsViewController(), transactionsViewController, ProfileViewController()]
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = viewControllers.map {
            $0.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "navBar-signOut"), style: .plain, target: self, action: #selector(AppDelegate.signOutButtonTouched(_:)))
            return NavigationController(rootViewController: $0)
        }
        tabBarController.tabBar.barTintColor = UIColor(hex: "#003ca6")
        tabBarController.tabBar.unselectedItemTintColor = UIColor(hex: "#7c85bc")
        tabBarController.tabBar.tintColor = .white
        tabBarController.tabBar.isTranslucent = false

        if animated {
            let transition = CATransition()
            transition.type = .reveal
            transition.subtype = .fromBottom
            transition.isRemovedOnCompletion = true
            transition.fillMode = .forwards
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
            transition.duration = 0.3
            window?.layer.add(transition, forKey: nil)
        }
        window?.rootViewController = tabBarController
    }

    func switchToLoginViewController(animated: Bool) {
        if animated {
            let transition = CATransition()
            transition.type = .reveal
            transition.subtype = .fromTop
            transition.isRemovedOnCompletion = true
            transition.fillMode = .forwards
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            transition.duration = 0.3
            window?.layer.add(transition, forKey: nil)
        }
        window?.rootViewController = LoginViewController()
    }

}

