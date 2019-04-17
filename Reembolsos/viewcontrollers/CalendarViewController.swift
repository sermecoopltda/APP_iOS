//
//  CalendarViewController.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/16/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

public typealias CalendarViewControllerSelectionHandler = (([TrackingModel], Date?) -> ())

class CalendarViewController: UIPageViewController {
    var trackingEvents: [TrackingModel] = []

    var dismissHandler: CalendarViewControllerSelectionHandler?
    var date: Date? = Date()

    convenience init() {
        self.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(CalendarViewController.cancel(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(CalendarViewController.done(_:)))

        if let date = date {
            let dateFormatter = DateFormatter()
            dateFormatter.setLocalizedDateFormatFromTemplate("MMMMyyyy")
            navigationItem.title = dateFormatter.string(from: date).localizedFirstCapitalized

            let controller = CalendarMonthViewController(initialDate: date)
            controller.selectionHandler = {
                (trackingEvents: [TrackingModel], date: Date?) in
                self.trackingEvents = trackingEvents
                self.date = date
            }
            setViewControllers([controller], direction: .forward, animated: false, completion: nil)
        }
    }

    // MARK: - Control Actions

    @objc func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @objc func done(_ sender: Any) {
        dismissHandler?(trackingEvents, date)
        dismiss(animated: true, completion: nil)
    }
}

extension CalendarViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? CalendarMonthViewController, let date = viewController.selectedDate, let newDate = Calendar.current.date(byAdding: .month, value: -1, to: date) else {
            return nil
        }
        let controller = CalendarMonthViewController(initialDate: newDate, selectsDay: false)
        controller.selectionHandler = {
            (trackingEvents: [TrackingModel], date: Date?) in
            self.trackingEvents = trackingEvents
            self.date = date
        }
        return controller
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? CalendarMonthViewController, let date = viewController.selectedDate, let newDate = Calendar.current.date(byAdding: .month, value: 1, to: date) else {
            return nil
        }
        let controller = CalendarMonthViewController(initialDate: newDate, selectsDay: false)
        controller.selectionHandler = {
            (trackingEvents: [TrackingModel], date: Date?) in
            self.trackingEvents = trackingEvents
            self.date = date 
        }
        return controller
    }
}

extension CalendarViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed, let controller = viewControllers?.first as? CalendarMonthViewController, let date = controller.selectedDate else {
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMMyyyy")
        navigationItem.title = dateFormatter.string(from: date).localizedFirstCapitalized
        // self.date = nil
    }
}
