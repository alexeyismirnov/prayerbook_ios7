//
//  Extensions.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 03.12.14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

enum TimeIntervalUnit {
    case Seconds, Minutes, Hours, Days, Months, Years
    
    func dateComponents(interval: Int) -> NSDateComponents {
        let components:NSDateComponents = NSDateComponents()
        
        switch (self) {
        case .Seconds:
            components.second = interval
        case .Minutes:
            components.minute = interval
        case .Days:
            components.day = interval
        case .Months:
            components.month = interval
        case .Years:
            components.year = interval
        default:
            components.day = interval
        }
        return components
    }
}

struct TimeInterval {
    var interval: Int
    var unit: TimeIntervalUnit
    
    init(interval: Int, unit: TimeIntervalUnit) {
        self.interval = interval
        self.unit = unit
    }
}

// FYI: http://stackoverflow.com/questions/24116271/whats-the-cleanest-way-of-applying-map-to-a-dictionary-in-swift

extension Int {
    var days: TimeInterval {
        return TimeInterval(interval: self, unit: TimeIntervalUnit.Days);
    }
    
    var months: TimeInterval {
        return TimeInterval(interval: self, unit: TimeIntervalUnit.Months);
    }
}

func - (let left:NSDate, let right:TimeInterval) -> NSDate {
    let calendar = NSCalendar.currentCalendar()
    let components = right.unit.dateComponents(-right.interval)
    return calendar.dateByAddingComponents(components, toDate: left, options: [])!
}

func + (let left:NSDate, let right:TimeInterval) -> NSDate {
    let calendar = NSCalendar.currentCalendar()
    let components = right.unit.dateComponents(right.interval)
    return calendar.dateByAddingComponents(components, toDate: left, options: [])!
}

extension NSDateComponents {
    convenience init(_ day: Int, _ month:Int, _ year: Int) {
        self.init()
        
        self.day = day
        self.month = month
        self.year = year
    }
    
    convenience init(date: NSDate) {
        self.init()
        
        let calendar = NSCalendar.currentCalendar()
        let dateComponents = calendar.components([.Day, .Month, .Year, .Weekday], fromDate: date)
        
        self.day = dateComponents.day
        self.month = dateComponents.month
        self.year = dateComponents.year
        self.weekday = dateComponents.weekday
    }
    
    func toDate() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        return calendar.dateFromComponents(self)!
    }
}

extension NSDate {
    convenience init(_ day: Int, _ month:Int, _ year: Int) {
        self.init(timeInterval: 0, sinceDate: NSDateComponents(day, month, year).toDate())
    }

    var day: Int {
        get {
            return NSDateComponents(date: self).day
        }
    }

    var weekday: Int {
        get {
            return NSDateComponents(date: self).weekday
        }
    }
    
    var month: Int {
        get {
            return NSDateComponents(date: self).month
        }
    }

    var year: Int {
        get {
            return NSDateComponents(date: self).year
        }
    }

}


func + (str: String, date: NSDate) -> String {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .ShortStyle
    formatter.timeStyle = .NoStyle
    
    return formatter.stringFromDate(date)
}

func + (arg1: NSMutableAttributedString?, arg2: NSMutableAttributedString?) -> NSMutableAttributedString? {
    
    if let rightArg = arg2 {
        if let leftArg = arg1 {
            let result = NSMutableAttributedString(attributedString: leftArg)
            result.appendAttributedString(rightArg)
            return result
            
        } else {
            return arg2
        }
        
    } else {
        return arg1
    }
    
}

func + (arg1: NSMutableAttributedString?, arg2: String?) -> NSMutableAttributedString? {
    
    if let rightArg = arg2 {
        if let leftArg = arg1 {
            let result = NSMutableAttributedString(attributedString: leftArg)
            result.appendAttributedString(NSMutableAttributedString(string: rightArg))
            return result
            
        } else {
            return NSMutableAttributedString(string: rightArg)
        }
        
    } else {
        return arg1
    }
}

func + (arg1: NSMutableAttributedString?, arg2: (String?, UIColor)) -> NSMutableAttributedString? {
    
    if let rightArg = arg2.0 {
        if let leftArg = arg1 {
            let result = NSMutableAttributedString(attributedString: leftArg)
            result.appendAttributedString(NSMutableAttributedString(string: rightArg, attributes: [NSForegroundColorAttributeName: arg2.1]))
            return result
            
        } else {
            return NSMutableAttributedString(string: rightArg, attributes: [NSForegroundColorAttributeName: arg2.1])
        }
        
    } else {
        return arg1
    }
}

func += <K,V> (inout left: Dictionary<K, [V]>, right: Dictionary<K, [V]>) {
    for (k, v) in right {
        if let leftValue = left[k] {
            left.updateValue(v + leftValue, forKey: k)
        } else {
            left.updateValue(v, forKey: k)
        }
    }
}

func +=<K, V> (inout left: [K:V], right: [K:V]) {
    for (k, v) in right { left[k] = v }
}

struct DateRange : SequenceType {
    var startDate: NSDate
    var endDate: NSDate
    
    init (_ arg1: NSDate, _ arg2: NSDate){
        startDate = arg1-1.days
        endDate = arg2
    }
    
    func generate() -> Generator {
        return Generator(range: self)
    }
    
    struct Generator: GeneratorType {
        var range: DateRange
        
        mutating func next() -> NSDate? {
            let nextDate = range.startDate + 1.days
            
            if range.endDate < nextDate {
                return nil
            }
            else {
                range.startDate = nextDate
                return nextDate
            }
        }
    }
}

extension NSDate: Comparable {
}

public func < (let left:NSDate, let right: NSDate) -> Bool {
    let result:NSComparisonResult = left.compare(right)
    return (result == .OrderedAscending)
}

public func == (let left:NSDate, let right: NSDate) -> Bool {
    let result:NSComparisonResult = left.compare(right)
    return (result == .OrderedSame)
}

func >> (left: NSDate, right: NSDate) -> Int {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components(.Day, fromDate: left, toDate: right, options: [])
    return components.day
}

extension String {
    subscript (i: Int) -> String {
        return String(Array(self.characters)[i])
    }
}

// http://stackoverflow.com/a/29218836/995049
extension UIColor {
    convenience init(hex: String) {
        let alpha: Float = 100
        
        // Establishing the rgb color
        var rgb: UInt32 = 0
        let s: NSScanner = NSScanner(string: hex)
        // Setting the scan location to ignore the leading `#`
        s.scanLocation = 1
        // Scanning the int into the rgb colors
        s.scanHexInt(&rgb)
        
        // Creating the UIColor from hex int
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha / 100)
        )
    }
}

extension UIImage {
    func maskWithColor(color: UIColor) -> UIImage {
        
        let maskImage = self.CGImage
        let width = self.size.width
        let height = self.size.height
        let bounds = CGRectMake(0, 0, width, height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        let bitmapContext = CGBitmapContextCreate(nil, Int(width), Int(height), 8, 0, colorSpace, bitmapInfo.rawValue)
        
        CGContextClipToMask(bitmapContext, bounds, maskImage)
        CGContextSetFillColorWithColor(bitmapContext, color.CGColor)
        CGContextFillRect(bitmapContext, bounds)
        
        let cImage = CGBitmapContextCreateImage(bitmapContext)
        let coloredImage = UIImage(CGImage: cImage!)
        
        return coloredImage
    }
    
    func resize(sizeChange:CGSize)-> UIImage {
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }

}

