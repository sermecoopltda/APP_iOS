//
//  CalendarMonthViewController.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 4/16/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import UIKit

class CalendarMonthViewController: UIViewController {
    var selectionHandler: CalendarViewControllerSelectionHandler?

    private struct statics {
        static let cellIdentifier = "cellIdentifier"
    }

    @IBOutlet var headerView: UIView!
    @IBOutlet var headerStackView: UIStackView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var separatorHeightConstraint: NSLayoutConstraint!

    var events: [DateDrivenEntryProtocol] = []

    private(set) var selectedDate: Date? {
        set {
            guard let newValue = newValue else {
                return
            }
            let calendar = Calendar.current
            selectedYear = calendar.component(.year, from: newValue)
            selectedMonth = calendar.component(.month, from: newValue)
            selectedDay = calendar.component(.day, from: newValue)
        }

        get {
            guard selectedYear > 0, selectedMonth > 0 else {
                return nil
            }
            let calendar = Calendar.current
            let components = DateComponents(year: selectedYear, month: selectedMonth, day: max(selectedDay, 1))
            return calendar.date(from: components)
        }
    }

    fileprivate var selectedYear: Int = 0
    fileprivate var selectedMonth: Int = 0
    fileprivate var selectedDay: Int = 0

    fileprivate var selectableDays: Set<Int> = [] {
        didSet {
            if isViewLoaded {
                collectionView.reloadData()
                // selectCurrentDay()
            }
        }
    }

    fileprivate var numberOfDaysInMonth: Int {
        let components = DateComponents(year: selectedYear, month: selectedMonth)
        let calendar = Calendar.current
        guard let date = calendar.date(from: components), let range = calendar.range(of: .day, in: .month, for: date) else {
            return 0
        }
        return range.count
    }

    fileprivate var weekdayForFirstDayOfMonth: Int {
        // sunday = 1; monday = 2; etc
        let components = DateComponents(year: selectedYear, month: selectedMonth)
        var calendar = Calendar.current
        calendar.locale = Locale.current
        guard let date = calendar.date(from: components) else {
            return -1
        }
        var weekday = calendar.component(.weekday, from: date) - calendar.firstWeekday
        if weekday < 0 {
            weekday += 7
        }
        return weekday
    }

    fileprivate var mode: CalendarMode = .tracking

    convenience init(initialDate date: Date, mode: CalendarMode) {
        self.init(nibName: nil, bundle: nil)
        selectedDate = date
        self.mode = mode 
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: String(describing: CalendarCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: statics.cellIdentifier)
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        separatorHeightConstraint.constant = 1 / UIScreen.main.nativeScale

        var calendar = Calendar.current
        calendar.locale = Locale.current
        var weekdays = calendar.veryShortStandaloneWeekdaySymbols
        let firstDayOffset = calendar.firstWeekday - 1
        for _ in 0..<firstDayOffset {
            weekdays.append(weekdays.removeFirst())
        }

        for weekday in weekdays {
            let label = UILabel(frame: .zero)
            label.font = UIFont.preferredFont(forTextStyle: .caption1)
            label.textAlignment = .center
            label.text = weekday
            headerStackView.addArrangedSubview(label)
        }

        guard selectedYear > 0, selectedMonth > 0 else {
            return
        }

        switch mode {
        case .tracking:
            APIClient.shared.tracking(month: selectedMonth, year: selectedYear, completionHandler: {
                (success: Bool, trackingEvents: [TransactionModel]) in
                if success {
                    let calendar = Calendar.current
                    self.events = trackingEvents
                    self.selectableDays = Set(trackingEvents.map {
                        return calendar.component(.day, from: $0.createdAt)
                    })
                    self.selectionHandler?(trackingEvents, self.selectedDate)
                }
            })

        case .history:
            APIClient.shared.history(month: selectedMonth, year: selectedYear, completionHandler: {
                (success: Bool, historyEvents: [HistoricModel]) in
                if success {
                    let calendar = Calendar.current
                    self.events = historyEvents
                    self.selectableDays = Set(historyEvents.map {
                        return calendar.component(.day, from: $0.createdAt)
                    })
                    self.selectionHandler?(historyEvents, self.selectedDate)
                }
            })
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // selectCurrentDay()
    }

    private func selectCurrentDay() {
        if selectedDay > 0 {
            let item = weekdayForFirstDayOfMonth + selectedDay - 1
            let indexPath = IndexPath(item: item, section: 0)
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        }
    }
}

extension CalendarMonthViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfDaysInMonth + weekdayForFirstDayOfMonth
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: statics.cellIdentifier, for: indexPath) as! CalendarCollectionViewCell
        let day: Int = max(0, indexPath.row + 1 - weekdayForFirstDayOfMonth)
        if day > 0 {
            cell.numberLabel.text = String(day)
            cell.isSelectable = selectableDays.contains(day)
        }
        return cell
    }
}

extension CalendarMonthViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let day: Int = max(0, indexPath.item + 1 - weekdayForFirstDayOfMonth)
        if day <= 0 {
            return false
        }
        return selectableDays.contains(day)
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let day: Int = max(0, indexPath.item + 1 - weekdayForFirstDayOfMonth)
        if day <= 0 {
            return false
        }
        return selectableDays.contains(day)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let desiredDay = max(0, indexPath.item + 1 - weekdayForFirstDayOfMonth)
        if selectedDay == desiredDay {
            selectedDay = 0
            collectionView.deselectItem(at: indexPath, animated: false)
        } else {
            selectedDay = desiredDay
        }
        guard let selectedDate = selectedDate else { return }
        let calendar = Calendar.current
        selectionHandler?(events.filter {
            if selectedDay == 0 { return true }
            return calendar.isDate($0.createdAt, inSameDayAs: selectedDate)
        }, selectedDate)
//        selectionHandler?(selectedDate)
//        let isSelected = collectionView.cellForItem(at: indexPath)?.isSelected ?? false
//        NSLog("selectedDay: \(selectedDay); isSelected: \(isSelected)")
    }
}

extension CalendarMonthViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.size.width / 7
        return CGSize(width: width, height: width)
    }
}
