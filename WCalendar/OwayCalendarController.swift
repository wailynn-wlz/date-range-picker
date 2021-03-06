//
//  ViewController.swift
//  WCalendar
//
//  Created by WaiLynnZaw on 8/17/17.
//  Copyright © 2017 moandlab. All rights reserved.
//

import UIKit
import JTAppleCalendar
class OwayCalendarController: UIViewController {
    let formatter = DateFormatter()
    @IBOutlet var calendarView: JTAppleCalendarView!
    @IBOutlet var monthLabel: UILabel!
    @IBOutlet var departDay: UILabel!
    @IBOutlet var departMonth: UILabel!
    @IBOutlet var departWDay: UILabel!
    @IBOutlet var departHighLightView: UIView!
    @IBOutlet var returnDay: UILabel!
    @IBOutlet var returnMonth: UILabel!
    @IBOutlet var returnWDay: UILabel!
    @IBOutlet var returnHighlightView: UIView!
    
    @IBOutlet var departView: UIView!
    @IBOutlet var returnView: UIView!
    @IBOutlet var placeholderView: UIView!
    
    var firstDate: Date?
    var lastDate: Date?
    
    var isOneWay:Bool = false

    var departTouch: Bool = true

    var validDate: Date = Date()

    let dayColor = UIColor(red:0.14, green:0.47, blue:0.89, alpha:1.0)
    let invalidDayColor = UIColor.gray
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCalendarView()
        firstDate = validDate
        lastDate = validDate.after2days
        
        if isOneWay == true {
            showHeaderDate(firstDate!, firstDate!)
            calendarView.selectDates([firstDate!])
        } else {
            showHeaderDate(firstDate!, lastDate!)
            calendarView.selectDates(from: firstDate!, to: lastDate!, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
        }
    }

    func toggleTouch() {
        departTouch = !departTouch
    }
    
    func focusDepart(_ flag: Bool){
        departHighLightView.isHidden = !flag
        returnHighlightView.isHidden = flag
    }
    
    func setUpCalendarView(){
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        calendarView.allowsMultipleSelection = !isOneWay
        calendarView.isRangeSelectionUsed = true
        calendarView.visibleDates { (visibleDates) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
    }
    
    func handleCellSelected(_ view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? DateCell else { return }
        
        switch cellState.selectedPosition() {
        case .full:
            validCell.selectedView.isHidden = false
            validCell.middleView.isHidden = true
            validCell.leftView.isHidden = true
            validCell.rightView.isHidden = true
            validCell.dateLabel.textColor = UIColor.white
        case .left:
            validCell.selectedView.isHidden = false
            validCell.middleView.isHidden = true
            validCell.leftView.isHidden = false
            validCell.rightView.isHidden = true
            validCell.dateLabel.textColor = UIColor.white
        case .right:
            validCell.selectedView.isHidden = false
            validCell.middleView.isHidden = true
            validCell.leftView.isHidden = true
            validCell.rightView.isHidden = false
            validCell.dateLabel.textColor = UIColor.white
        case .middle:
            validCell.selectedView.isHidden = true
            validCell.middleView.isHidden = false
            validCell.leftView.isHidden = true
            validCell.rightView.isHidden = true
            validCell.dateLabel.textColor = dayColor
        default:
            validCell.selectedView.isHidden = true
            validCell.middleView.isHidden = true
            validCell.leftView.isHidden = true
            validCell.rightView.isHidden = true
        }
        if cellState.dateBelongsTo != .thisMonth {
            validCell.selectedView.isHidden = true
            validCell.middleView.isHidden = true
            validCell.leftView.isHidden = true
            validCell.rightView.isHidden = true
        }

    }
    func handleCellTextColor(_ view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? DateCell else { return }

            if cellState.dateBelongsTo == .thisMonth {
                if cellState.date < validDate {
                    validCell.dateLabel.textColor = invalidDayColor
                } else {
                    validCell.dateLabel.textColor = dayColor
                }
            } else {
                validCell.dateLabel.textColor = invalidDayColor
            }

    }
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        let date =  visibleDates.monthDates.first!.date
        self.formatter.dateFormat = "MMMM yyyy"
        self.monthLabel.text = self.formatter.string(from: date)
        focusDepart(true)
    }
    
    func showHeaderDate(_ depart: Date, _ returnDate: Date){
        
        returnView.isHidden = isOneWay
        placeholderView.isHidden = !isOneWay
        
        self.formatter.dateFormat = "dd"
        self.departDay.text = self.formatter.string(from: depart)
        self.returnDay.text = self.formatter.string(from: returnDate)
        
        self.formatter.dateFormat = "MMM"
        self.departMonth.text = self.formatter.string(from: depart)
        self.returnMonth.text = self.formatter.string(from: returnDate)
        
        self.formatter.dateFormat = "EEE"
        self.departWDay.text = self.formatter.string(from: depart)
        self.returnWDay.text = self.formatter.string(from: returnDate)
    }
    
    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        let selectedDates = calendarView.selectedDates
        formatter.dateFormat = "yyyy-MM-dd"
        print("FROM \(formatter.string(from: selectedDates.first!)) -> TO \(formatter.string(from: selectedDates.last!))")
    }
}
extension OwayCalendarController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = Date()
        let endDate = formatter.date(from: "2100 12 31")
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate!, calendar: Calendar.current)
        return parameters
    }
}

extension OwayCalendarController: JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        cell.dateLabel.text = cellState.text

        if cellState.dateBelongsTo == .thisMonth {
            cell.dateLabel.isHidden = false
        } else {
            cell.dateLabel.isHidden = true
        }
        handleCellTextColor(cell, cellState: cellState)
        handleCellSelected(cell, cellState: cellState)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellTextColor(cell, cellState: cellState)
        handleCellSelected(cell, cellState: cellState)
        focusDepart(true)
        if isOneWay == true {
            showHeaderDate(date, date)
        } else {
            if departTouch == false && date < firstDate! {
                toggleTouch()
            }
            calendar.deselectAllDates(triggerSelectionDelegate: false)
            if departTouch {
                firstDate = date
                focusDepart(true)
                calendar.selectDates(from: firstDate!, to: date, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
                showHeaderDate(firstDate!, date)
                toggleTouch()
            } else {
                lastDate = date
                focusDepart(false)
                toggleTouch()
                calendar.selectDates(from: firstDate!, to: lastDate ?? date, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
                showHeaderDate(firstDate!, lastDate ?? date)
            }
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        if cellState.dateBelongsTo != .thisMonth {
            return false
        } else {
            if date < validDate {
                return false
            }
        }
        return true
    }

    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellTextColor(cell, cellState: cellState)
        handleCellSelected(cell, cellState: cellState)
        if isOneWay == true {
            showHeaderDate(date, date)
        } else {
            calendar.deselectAllDates(triggerSelectionDelegate: false)
            let firstDiff = date.interval(ofComponent: .day, fromDate: firstDate!)
            let lastDiff = lastDate!.interval(ofComponent: .day, fromDate: date)

            if firstDiff < lastDiff {
                self.firstDate = date
            } else {
                self.lastDate = date
            }
            showHeaderDate(firstDate!, lastDate!)
            calendar.selectDates(from: firstDate!, to: lastDate!, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
extension Date {
    
    var after1day: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }
    
    var after2days: Date {
        return Calendar.current.date(byAdding: .day, value: 2, to: self)!
    }
    
    var last1day: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
    
    var nextMonth: Date {
        return Calendar.current.date(byAdding: .month, value: 1, to: self)!
    }
    
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
    
    func next6Month() -> Date {
        return Calendar.current.date(byAdding: .month, value: 6, to: self)!
    }
    
    func lastXYears(_ year: Int) -> Date {
        return Calendar.current.date(byAdding: .year, value: -year, to: self)!
    }

    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {

        let currentCalendar = Calendar.current

        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }

        return end - start
    }
}
