//
//  SegmentedViewController.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/19/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

class SegmentedViewController: UIViewController {
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var contentView: UIView!

    private var selectedSegmentIndex: Int = -1 {
        didSet {
            guard let viewControllers = viewControllers, selectedSegmentIndex >= 0 && selectedSegmentIndex < viewControllers.count && isViewLoaded else {
                return
            }
            let viewController = viewControllers[selectedSegmentIndex]
            segmentedControl.selectedSegmentIndex = selectedSegmentIndex
            switchTo(viewController: viewController)
        }
    }

    weak var currentViewController: UIViewController?

    var viewControllers: [UIViewController]? = [] {
        willSet {
            if let viewControllers = viewControllers {
                for viewController in viewControllers {
//                    if let someTabBarItem = viewController.tabBarItem as? ObservableTabBarItem {
//                        someTabBarItem.badgeValueDidChangeHandler = nil
//                    }
                    viewController.willMove(toParent: nil)
                    viewController.view.removeFromSuperview()
                    viewController.removeFromParent()
                }
            }
            currentViewController = nil
        }

        didSet {
            if let viewControllers = viewControllers {
                for viewController in viewControllers {
                    addChild(viewController)
                    viewController.didMove(toParent: self)

//                    let someTabBarItem = ObservableTabBarItem()
//                    someTabBarItem.title = title(forViewController: viewController)
//                    someTabBarItem.badgeValueDidChangeHandler = {
//                        (tabBarItem: UITabBarItem) in
//                        self.updateBadgeValue()
//                    }
//                    viewController.tabBarItem = someTabBarItem
                }
            }
            if isViewLoaded {
                refreshSegmentedControl()
            }
            guard let count = viewControllers?.count else {
                selectedSegmentIndex = -1
                return
            }
            selectedSegmentIndex = (count > 0 ? 0 : -1)
        }
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: String(describing: SegmentedViewController.self), bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.titleView = segmentedControl
        refreshSegmentedControl()
        if let viewControllers = viewControllers, viewControllers.count > 0 {
            selectedSegmentIndex = 0
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let currentViewController = currentViewController, currentViewController.isViewLoaded {
            currentViewController.view.frame = contentView.bounds
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func updateBadgeValue() {
        guard let viewControllers = viewControllers else {
            tabBarItem.badgeValue = nil
            return
        }
        var count = 0
        for viewController in viewControllers {
            if let badgeValue = viewController.tabBarItem.badgeValue, let localCount = Int(badgeValue) {
                count += localCount
            }
        }
        tabBarItem.badgeValue = (count > 0) ? String(count) : nil
//        if isViewLoaded {
//            segmentedControl.badgeValue = tabBarItem.badgeValue
//        }
    }

    // MARK: - Control Actions

    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        selectedSegmentIndex = segmentedControl.selectedSegmentIndex
    }

    // MARK: - Private Methods

    private func refreshSegmentedControl() {
        segmentedControl.removeAllSegments()
        defer {
            segmentedControl.sizeToFit()
        }
        guard let viewControllers = viewControllers else {
            return
        }
        for viewController in viewControllers {
            segmentedControl.insertSegment(withTitle: title(forViewController: viewController), at: segmentedControl.numberOfSegments, animated: false)
        }
//        segmentedControl.badgeValue = tabBarItem.badgeValue
    }

    private func switchTo(viewController: UIViewController) {
        viewController.view.frame = contentView.bounds
        if let currentViewController = currentViewController {
            transition(from: currentViewController,
                       to: viewController,
                       duration: 0,
                       options: [],
                       animations: nil,
                       completion: {
                        (finished: Bool) in
                        self.currentViewController = viewController
            })
        } else {
            contentView.addSubview(viewController.view)
            viewController.didMove(toParent: self)
            currentViewController = viewController
        }
    }

    private func title(forViewController viewController: UIViewController) -> String {
        return viewController.navigationItem.title ?? viewController.title ?? viewController.tabBarItem.title ?? String(describing: viewController)
    }
}
