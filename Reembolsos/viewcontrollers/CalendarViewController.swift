//
//  CalendarViewController.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/16/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

public typealias CalendarViewControllerSelectionHandler = (([DateDrivenEntryProtocol], Date?) -> ())

enum CalendarMode {
    case tracking
    case history
}

class CalendarViewController: UIPageViewController {
    var trackingEvents: [DateDrivenEntryProtocol] = []

    var dismissHandler: CalendarViewControllerSelectionHandler?
    var date: Date? = Date()

    fileprivate var mode: CalendarMode = .tracking

    fileprivate let navControl = CalendarNavControl.control()

    convenience init(mode: CalendarMode) {
        self.init(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        self.mode = mode
        navControl.nextButtonHandler = {
            self.jumpToNextMonth(animated: true)
        }
        navControl.prevButtonHandler = {
            self.jumpToPreviousMonth(animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(CalendarViewController.cancel(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(CalendarViewController.done(_:)))

        if let date = date {
            let dateFormatter = DateFormatter()
            dateFormatter.setLocalizedDateFormatFromTemplate("MMMyyyy")
            navControl.title = dateFormatter.string(from: date).localizedFirstCapitalized
            navigationItem.titleView = navControl
//            navigationItem.title = dateFormatter.string(from: date).localizedFirstCapitalized

            let controller = CalendarMonthViewController(initialDate: date, mode: mode)
            controller.selectionHandler = {
                (events: [DateDrivenEntryProtocol], date: Date?) in
                self.trackingEvents = events
                self.date = date
            }
            setViewControllers([controller], direction: .forward, animated: false, completion: nil)
        }
    }

    fileprivate func jumpToNextMonth(animated: Bool) {
        let calendar = Calendar.current
        guard let monthController = viewControllers?.first as? CalendarMonthViewController, let date = monthController.selectedDate, let newDate = calendar.date(byAdding: .month, value: 1, to: date) else { return }
        let controller = CalendarMonthViewController(initialDate: newDate, mode: mode)
        controller.selectionHandler = {
            (events: [DateDrivenEntryProtocol], date: Date?) in
            self.trackingEvents = events
            self.date = date
        }
        setViewControllers([controller], direction: .forward, animated: animated, completion: {
            (finished: Bool) in
            if !finished { return }
            let dateFormatter = DateFormatter()
            dateFormatter.setLocalizedDateFormatFromTemplate("MMMyyyy")
            self.navControl.title = dateFormatter.string(from: newDate).localizedFirstCapitalized
        })
    }

    fileprivate func jumpToPreviousMonth(animated: Bool) {
        let calendar = Calendar.current
        guard let monthController = viewControllers?.first as? CalendarMonthViewController, let date = monthController.selectedDate, let newDate = calendar.date(byAdding: .month, value: -1, to: date) else { return }
        let controller = CalendarMonthViewController(initialDate: newDate, mode: mode)
        controller.selectionHandler = {
            (events: [DateDrivenEntryProtocol], date: Date?) in
            self.trackingEvents = events
            self.date = date
        }
        setViewControllers([controller], direction: .reverse, animated: animated, completion: {
            (finished: Bool) in
            if !finished { return }
            let dateFormatter = DateFormatter()
            dateFormatter.setLocalizedDateFormatFromTemplate("MMMyyyy")
            self.navControl.title = dateFormatter.string(from: newDate).localizedFirstCapitalized
        })
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
        let controller = CalendarMonthViewController(initialDate: newDate, mode: mode)
        controller.selectionHandler = {
            (events: [DateDrivenEntryProtocol], date: Date?) in
            self.trackingEvents = events
            self.date = date
        }
        return controller
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? CalendarMonthViewController, let date = viewController.selectedDate, let newDate = Calendar.current.date(byAdding: .month, value: 1, to: date) else {
            return nil
        }
        let controller = CalendarMonthViewController(initialDate: newDate, mode: mode)
        controller.selectionHandler = {
            (events: [DateDrivenEntryProtocol], date: Date?) in
            self.trackingEvents = events
            self.date = date 
        }
        return controller
    }
}

extension CalendarViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        NSLog("pageViewController didFinishAnimating")
        guard completed, let controller = viewControllers?.first as? CalendarMonthViewController, let date = controller.selectedDate else {
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMyyyy")
        navControl.title = dateFormatter.string(from: date).localizedFirstCapitalized
//        navigationItem.titleView = navControl
        // navigationItem.title = dateFormatter.string(from: date).localizedFirstCapitalized
        // self.date = nil
    }
}
