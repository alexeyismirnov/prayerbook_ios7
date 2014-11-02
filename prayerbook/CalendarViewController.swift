//
//  CalendarViewController.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/8/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController, RDVCalendarViewDelegate {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var calendarView: RDVCalendarView!
    weak var delegate: DailyPrayers!

    override func viewDidLoad() {
        super.viewDidLoad()

        var button_left = UIBarButtonItem(image: UIImage(named: "arrow-left"), style: .Plain, target: self, action: "prev_month")
        var button_right = UIBarButtonItem(image: UIImage(named: "arrow-right"), style: .Plain, target: self, action: "next_month")
        button_left.imageInsets = UIEdgeInsetsMake(0,0,0,-20)
        
        navigationItem.rightBarButtonItems = [button_right, button_left]

        calendarView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        calendarView.separatorStyle = .Horizontal
        calendarView.delegate = self
        calendarView.backgroundColor = UIColor.whiteColor()
        calendarView.currentDayColor = UIColor.whiteColor()

        title =  calendarView.monthLabel.text
    }
    
    override func viewWillAppear(animated: Bool) {
        calendarView.selectedDate = delegate.currentDate
        updateDescription()
    }
    
    func prev_month() {
        calendarView.selectedDate = nil
        calendarView.showPreviousMonth()
    }
    
    func next_month() {
        calendarView.selectedDate = nil
        calendarView.showNextMonth()
    }
    
    @IBAction func done(sender: AnyObject) {
        delegate.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func doneWithDate(recognizer: UITapGestureRecognizer) {
        let cell = recognizer.view as RDVCalendarDayCell
        let index = calendarView.indexForDayCell(cell)
        var currentDate = NSDateComponents(index+1, calendarView.month.month, calendarView.month.year).toDate()

        delegate.currentDate = currentDate
        delegate.reload()
        delegate.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func updateDescription() {
        if calendarView.selectedDate == nil {
            descriptionLabel.attributedText = NSMutableAttributedString(string: "")
            
        } else {
            
            let currentDate = calendarView.selectedDate
            var description = FeastCalendar.getDayDescription(currentDate)
            
            if description == nil {
                description = description + (FeastCalendar.getWeekDescription(currentDate), UIColor.grayColor())
            }
                        
            descriptionLabel.attributedText = description
        }
        
    }
    
    // MARK: RDVCalendarViewDelegate
    
    func calendarView(calendarView: RDVCalendarView!, didChangeMonth month: NSDateComponents!) {
        title = calendarView.monthLabel.text
        updateDescription()
    }
    
    func calendarView(calendarView: RDVCalendarView!, configureDayCell dayCell: RDVCalendarDayCell!, atIndex index: Int) {
        // FIXME: refactor to use just one gesture recognizer attached to RDVCalendarView
        var recognizer = UITapGestureRecognizer(target: self, action:Selector("doneWithDate:"))
        recognizer.numberOfTapsRequired = 2
        dayCell.addGestureRecognizer(recognizer)
        
        var curDate = NSDateComponents(index+1, calendarView.month.month, calendarView.month.year).toDate()
        dayCell.textLabel.textColor = (FeastCalendar.isGreatFeast(curDate)) ? UIColor.redColor() : UIColor.blackColor()

        if let fasting = FeastCalendar.getFastingDescription(curDate) {
            switch fasting.0 {
            case .Vegetarian:
                dayCell.backgroundColor = UIColor.greenColor()
                break
            case .FishAllowed:
                dayCell.backgroundColor = UIColor.yellowColor()
                break
            case .Cheesefare, .FastFree:
                dayCell.backgroundColor = UIColor.cyanColor()
                break
            default:
                dayCell.backgroundColor = UIColor.whiteColor()
                break
            }
        }

    }
    
    func calendarView(calendarView: RDVCalendarView!, didSelectDate date: NSDate!) {
        updateDescription()
    }
    
}
