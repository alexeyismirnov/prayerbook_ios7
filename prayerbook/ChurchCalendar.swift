
import UIKit

enum FeastType: Int {
    case None=0, NoSign, SixVerse, Doxology, Polyeleos, Vigil, Great
}

enum NameOfDay: Int {
    case StartOfYear=0, Pascha, Pentecost, Ascension, PalmSunday, EveOfNativityOfGod=5, NativityOfGod, Circumcision, EveOfTheophany, Theophany, MeetingOfLord=10, Annunciation, NativityOfJohn, PeterAndPaul, Transfiguration, Dormition=15, BeheadingOfJohn, NativityOfTheotokos, ExaltationOfCross, Veil, EntryIntoTemple=20, StNicholas, BeginningOfGreatLent, ZacchaeusSunday, SundayOfPublicianAndPharisee, SundayOfProdigalSon=25, SundayOfDreadJudgement, BeginningOfDormitionFast, BeginningOfNativityFast, BeginningOfApostolesFast, SundayOfForefathers=30, SundayOfFathers, SundayAfterExaltation, SundayAfterExaltationPrevYear, SaturdayAfterExaltation, SaturdayBeforeExaltation=35, SundayBeforeExaltation, SaturdayBeforeNativity, SaturdayAfterNativity, SundayAfterNativity, SaturdayBeforeTheophany=40, SundayBeforeTheophany, SaturdayAfterTheophany, SundayAfterTheophany, FridayAfterExaltation, EndOfYear=45
}

enum FastingType: Int {
    case NoFast=0, Vegetarian, FishAllowed, FastFree, Cheesefare
}

enum DayOfWeek: Int  {
    case Sunday=1, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
}

struct DateCache : Hashable {
    let code : NameOfDay
    let year : Int
    init(_ code: NameOfDay, _ year: Int) {
        self.code = code
        self.year = year
    }
    var hashValue: Int {
        return code.hashValue ^ year.hashValue
    }
}

// MARK: Equatable

func == (lhs: DateCache, rhs: DateCache) -> Bool {
    return lhs.code == rhs.code && lhs.year == rhs.year
}

struct ChurchCalendar {
    
    static var dict: [[String : String]] = {
        let bundle = NSBundle.mainBundle().pathForResource("ChurchCalendar", ofType: "plist")
        let dict = NSArray(contentsOfFile: bundle!)
        return dict as! [[String : String]]
    }()
    
    static var formatter: NSDateFormatter = {
        var formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .NoStyle
        return formatter
    }()
    
    static var currentYear: Int!
    static var currentWeekday: DayOfWeek!
    static var feastDates = [NSDate: [NameOfDay]]()
    static var otherFeasts = [NSDate: [(FeastType, String)]]()
    static var dCache = [DateCache:NSDate]()

    static let feastIcon : [FeastType: String] = [
        .NoSign: "nosign",
        .SixVerse: "sixverse",
        .Doxology: "doxology",
        .Polyeleos: "polyeleos",
        .Vigil: "vigil",
        .Great: "great"
    ]

    static let greatFeastCodes : [NameOfDay] = [.PalmSunday, .Pascha, .Ascension, .Pentecost, .NativityOfGod, .Circumcision, .Theophany, .MeetingOfLord, .Annunciation, .NativityOfJohn, .PeterAndPaul, .Transfiguration, .Dormition, .BeheadingOfJohn, .NativityOfTheotokos, .ExaltationOfCross, .Veil, .EntryIntoTemple]

    static func saveFeastDate(code: NameOfDay, _ year:Int) {
        
        if (code == .SundayOfFathers || code == .SaturdayBeforeNativity) {
            // it is possible that there will be 2 Sundays of Fathers in a given year
            return;
        }
        
        var res = filter(feastDates, { (date, codes) in
            
            let targetYear = (code == .SundayAfterExaltationPrevYear) ? year-1 : year
            return contains(codes, code) && NSDateComponents(date:date).year == targetYear
        })
        
        dCache[DateCache(code, year)] = res[0].0
    }
    
    static func d(code: NameOfDay) -> NSDate {
        return dCache[DateCache(code, currentYear)]!
    }
    
    static func setDate(date: NSDate) {
        let dateComponents = NSDateComponents(date: date)
        currentYear = dateComponents.year
        currentWeekday = DayOfWeek(rawValue: dateComponents.weekday)
        
        if dCache[DateCache(.Pascha, currentYear)] == nil {
            generateMainFeasts(currentYear)
            generateOtherFeasts(currentYear)
        }
    }

    static func paschaDay(year: Int) -> NSDate {
        // http://calendar.lenacom.spb.ru/index.php
        let a = (19*(year%19) + 15) % 30
        let b = (2*(year%4) + 4*(year%7) + 6*a + 6) % 7
        return  ((a+b > 10) ? NSDateComponents(a+b-9, 4, year).toDate() : NSDateComponents(22+a+b, 3, year).toDate()) + 13.days
    }
    
    static func generateOtherFeasts(year: Int) {
        let pascha = paschaDay(year)
        let greatLentStart = pascha-48.days

        let sundays : [NSDate: [(FeastType, String)]] = [
            greatLentStart-1.days:  [(.None,   "Cheesefare Sunday (Forgiveness Sunday): Commemoration of the Expulsion of Adam from Paradise")],
            greatLentStart+6.days:  [(.None,   "First Sunday of Lent: Triumph of Orthodoxy")],
            greatLentStart+13.days: [(.None,   "Second Sunday of Great Lent"),
                                     (.NoSign, "Saint Gregory Palamas, Archbishop of Thessalonica († c. 1360)")],
            greatLentStart+20.days: [(.None,   "Third Sunday of Great Lent, Veneration of the Precious Cross")],
            greatLentStart+27.days: [(.None,   "Fourth Sunday of Great Lent"),
                                     (.NoSign, "Venerable John Climacus of Sinai, Author of “the Ladder” († 649)")],
            greatLentStart+34.days: [(.None,   "Fifth Sunday of Great Lent"),
                                     (.None,   "Venerable Mary of Egypt")],
            greatLentStart+40.days: [(.None,   "Saturday of Palms (Lazarus Saturday)")],
            pascha+7.days:          [(.None,   "Second Sunday after Pascha. Thomas Sunday, or Antipascha")],
            pascha+14.days:         [(.None,   "Third Sunday after Pascha. Sunday of the Myrrhbearing Women"),
                                     (.NoSign, "St Joseph of Arimathea, and Nicodemus"),
                                     (.NoSign, "Right-believing Tamara, Queen of Georgia († 1213)")],
            pascha+21.days:         [(.None,   "Fourth Sunday after Pascha. Sunday of the Paralytic"),
                                     (.NoSign, "Holy Martyr Abraham the Bulgar, Wonderworker of Vladimir († 1229) "),
                                     (.NoSign, "Righteous Tabitha of Joppa (1st C)")],
            pascha+28.days:         [(.None,   "Fifth Sunday after Pascha. Sunday of the Samaritan Woman")],
            pascha+35.days:         [(.None,   "Sixth Sunday after Pascha. Sunday of the Blind Man")],
            pascha+42.days:         [(.None,   "Seventh Sunday after Pascha. Commemoration of the 318 Holy Fathers of the First Ecumenical Council (325)"),
                                     (.None,   "Chelnskoy and Pskov-Kiev Caves called “Tenderness” icons of the Mother of God")],
            pascha+50.days:         [(.None,   "Day of the Holy Spirit"),
                                     (.None,   "Icons of the Mother of God “Tupichevsk” (1847) and “Cypriot” (392) ")],
        ]
        
        otherFeasts += sundays
    }
    
    static func generateMainFeasts(year: Int) {
        let pascha = paschaDay(year)
        let greatLentStart = pascha-48.days

        let movingFeasts : [NSDate: [NameOfDay]] = [
            greatLentStart-29.days:                   [.ZacchaeusSunday],
            greatLentStart-22.days:                   [.SundayOfPublicianAndPharisee],
            greatLentStart-15.days:                   [.SundayOfProdigalSon],
            greatLentStart-8.days:                    [.SundayOfDreadJudgement],
            greatLentStart:                           [.BeginningOfGreatLent],
            pascha-7.days:                            [.PalmSunday],
            pascha:                                   [.Pascha],
            pascha+39.days:                           [.Ascension],
            pascha+49.days:                           [.Pentecost],
            pascha+57.days:                           [.BeginningOfApostolesFast],
        ]
        
        let fixedFeasts : [NSDate: [NameOfDay]] = [
            NSDateComponents(1,  1, year).toDate():   [.StartOfYear],
            NSDateComponents(6,  1, year).toDate():   [.EveOfNativityOfGod],
            NSDateComponents(7,  1, year).toDate():   [.NativityOfGod],
            NSDateComponents(14, 1, year).toDate():   [.Circumcision],
            NSDateComponents(18, 1, year).toDate():   [.EveOfTheophany],
            NSDateComponents(19, 1, year).toDate():   [.Theophany],
            NSDateComponents(15, 2, year).toDate():   [.MeetingOfLord],
            NSDateComponents(7,  4, year).toDate():   [.Annunciation],
            NSDateComponents(7,  7, year).toDate():   [.NativityOfJohn],
            NSDateComponents(12, 7, year).toDate():   [.PeterAndPaul],
            NSDateComponents(14, 8, year).toDate():   [.BeginningOfDormitionFast],
            NSDateComponents(19, 8, year).toDate():   [.Transfiguration],
            NSDateComponents(28, 8, year).toDate():   [.Dormition],
            NSDateComponents(11, 9, year).toDate():   [.BeheadingOfJohn],
            NSDateComponents(21, 9, year).toDate():   [.NativityOfTheotokos],
            NSDateComponents(27, 9, year).toDate():   [.ExaltationOfCross],
            NSDateComponents(14, 10, year).toDate():  [.Veil],
            NSDateComponents(28, 11, year).toDate():  [.BeginningOfNativityFast],
            NSDateComponents(4,  12, year).toDate():  [.EntryIntoTemple],
            NSDateComponents(19, 12, year).toDate():  [.StNicholas],
            NSDateComponents(31, 12, year).toDate():  [.EndOfYear],
        ];

        feastDates += movingFeasts
        feastDates += fixedFeasts
        
        let exaltation = NSDateComponents(27, 9, year).toDate()
        let exaltationWeekday = NSDateComponents(date: exaltation).weekday
        feastDates += [exaltation + (8-exaltationWeekday).days: [.SundayAfterExaltation]]
        
        var exaltationFriOffset = (exaltationWeekday >= 6) ? 13-exaltationWeekday : 6-exaltationWeekday
        feastDates += [exaltation + exaltationFriOffset.days: [.FridayAfterExaltation]]
        
        var exaltationSatOffset = (exaltationWeekday == 7) ? 7 : 7-exaltationWeekday
        feastDates += [exaltation + exaltationSatOffset.days: [.SaturdayAfterExaltation]]
        
        var exaltationSunOffset = (exaltationWeekday == 1) ? 7 : exaltationWeekday-1
        feastDates += [exaltation - exaltationSunOffset.days: [.SundayBeforeExaltation]]

        feastDates += [exaltation - exaltationWeekday.days: [.SaturdayBeforeExaltation]]

        let exaltationPrevYear = NSDateComponents(27, 9, year-1).toDate()
        let exaltationPrevYearWeekday = NSDateComponents(date: exaltationPrevYear).weekday
        feastDates += [exaltationPrevYear + (8-exaltationPrevYearWeekday).days: [.SundayAfterExaltationPrevYear]]

        let nativity = NSDateComponents(7, 1, year).toDate()
        let nativityWeekday = NSDateComponents(date:nativity).weekday
        var nativitySunOffset = (nativityWeekday == 1) ? 7 : (nativityWeekday-1)
        if nativitySunOffset != 7 {
            feastDates += [nativity - nativitySunOffset.days: [.SundayOfFathers]]
        }

        if nativityWeekday != 7 {
            feastDates += [nativity - nativityWeekday.days: [.SaturdayBeforeNativity]]
        }

        feastDates += [nativity + (8-nativityWeekday).days: [.SundayAfterNativity]]
        
        var nativitySatOffset = (nativityWeekday == 7) ? 7 : 7-nativityWeekday
        feastDates += [nativity + nativitySatOffset.days: [.SaturdayAfterNativity]]
        
        let nativityNextYear = NSDateComponents(7, 1, year+1).toDate()
        let nativityNextYearWeekday = NSDateComponents(date:nativityNextYear).weekday
        nativitySunOffset = (nativityNextYearWeekday == 1) ? 7 : (nativityNextYearWeekday-1)

        if nativitySunOffset == 7 {
            feastDates += [nativityNextYear - nativitySunOffset.days: [.SundayOfFathers]]
        }
        
        if nativityNextYearWeekday == 7 {
            feastDates += [nativity - nativityNextYearWeekday.days: [.SaturdayBeforeNativity]]
        }
        
        nativitySunOffset += 7
        feastDates += [nativityNextYear - nativitySunOffset.days: [.SundayOfForefathers]]
        
        let theophany = NSDateComponents(19, 1, year).toDate()
        let theophanyWeekday = NSDateComponents(date:theophany).weekday

        var theophanySunOffset = (theophanyWeekday == 1) ?  7 : (theophanyWeekday-1)
        feastDates += [theophany - theophanySunOffset.days: [.SundayBeforeTheophany]]
        
        feastDates += [theophany - theophanyWeekday.days: [.SaturdayBeforeTheophany]]

        feastDates += [theophany + (8-theophanyWeekday).days: [.SundayAfterTheophany]]

        var theophanySatOffset = (theophanyWeekday == 7) ? 7 : 7-theophanyWeekday
        feastDates += [theophany + theophanySatOffset.days: [.SaturdayAfterTheophany]]

        let start: Int = NameOfDay.StartOfYear.rawValue
        let end: Int = NameOfDay.EndOfYear.rawValue
        
        for index in start...end {
            let code = NameOfDay(rawValue: index)
            saveFeastDate(code!, year)
        }

    }

    static func isGreatFeast(date: NSDate) -> Bool {
        if let feastCodes = feastDates[date] {
            for code in feastCodes {
                if contains(greatFeastCodes, code) {
                    return true
                }
            }
        }
        return false
    }
    
    static func getDayDescription(date: NSDate) -> [(FeastType, String)] {
        var result = [(FeastType, String)]()
        let sundays : [NameOfDay] = [.ZacchaeusSunday, .SundayOfPublicianAndPharisee, .SundayOfProdigalSon, .SundayOfDreadJudgement]
        
        setDate(date)

        if let codes = feastDates[date] {
            for code in codes {
                if contains(sundays, code) {
                    continue
                }
                
                if let str:String = dict[code.rawValue][Translate.language]  {
                    if !str.isEmpty {
                        result.append((contains(greatFeastCodes, code) ? .Great : .NoSign, str))
                    }
                }
            }
        }
        
        if let feasts = otherFeasts[date] {
            for feast in feasts {
                result.append((feast.0, Translate.s(feast.1)))
            }
        }
        
        return result
    }
    
    static func getWeekDescription(date: NSDate) -> String? {
        
        setDate(date)

        let dayOfWeek = (currentWeekday == .Sunday) ? "Sunday" : "Week"
        
        switch (date) {
        case d(.StartOfYear) ..< d(.SundayOfPublicianAndPharisee):
            if date == d(.ZacchaeusSunday) {
                return dict[NameOfDay.ZacchaeusSunday.rawValue][Translate.language] as String!

            } else {
                return  String(format: Translate.s("\(dayOfWeek) %d after Pentecost"), ((paschaDay(currentYear-1)+50.days) >> date)/7+1)
            }

        case d(.SundayOfPublicianAndPharisee):
            return dict[NameOfDay.SundayOfPublicianAndPharisee.rawValue][Translate.language] as String!
            
        case d(.SundayOfPublicianAndPharisee)+1.days ..< d(.SundayOfProdigalSon):
            return "Week of the Publican and the Pharisee"
        
        case d(.SundayOfProdigalSon):
            return dict[NameOfDay.SundayOfProdigalSon.rawValue][Translate.language] as String!
            
        case d(.SundayOfProdigalSon)+1.days ..< d(.SundayOfDreadJudgement):
            return "Week of the Prodigal Son"
        
        case d(.SundayOfDreadJudgement):
            return dict[NameOfDay.SundayOfDreadJudgement.rawValue][Translate.language] as String!
            
        case d(.SundayOfDreadJudgement)+1.days ..< d(.BeginningOfGreatLent)-1.days:
            return "Week of the Dread Judgement"

        case d(.BeginningOfGreatLent) ..< d(.PalmSunday):
            let weekNum = (d(.BeginningOfGreatLent) >> date)/7+1
            
            if currentWeekday == .Sunday {
                return nil
            } else {
                return "Week \(weekNum) of Great Lent"
            }
            
        case d(.PalmSunday)+1.days ..< d(.Pascha):
            return "Passion Week"
            
        case d(.Pascha)+1.days ..< d(.Pascha)+7.days:
            return "Bright Week"
            
        case d(.Pascha)+8.days ..< d(.Pentecost):
            let weekNum = (d(.Pascha) >> date)/7+1
            
            if currentWeekday == .Sunday {
                return nil

            } else {
                return  "Week \(weekNum) after Pascha"
            }

        case d(.Pentecost)+1.days ..< d(.Pentecost)+7.days:
            return "Trinity Week"
            
        case d(.Pentecost)+7.days ... d(.EndOfYear):
            return  String(format: Translate.s("\(dayOfWeek) %d after Pentecost"), ((d(.Pentecost)+1.days) >> date)/7+1)
            
        default: return nil
        }
        
    }
    
    static func getToneDescription(date: NSDate) -> String? {
        func tone(#dayNum: Int) -> Int {
            let reminder = (dayNum/7) % 8
            return (reminder == 0) ? 8 : reminder
        }
        
        var formatter = NSNumberFormatter()
        formatter.locale = Translate.locale
        
        if Translate.language == "cn" {
            formatter.numberStyle = .SpellOutStyle
        }

        setDate(date)

        switch (date) {
        case d(.StartOfYear) ..< d(.PalmSunday):
            return String(format: Translate.s("Tone %@"), formatter.stringFromNumber(tone(dayNum: paschaDay(currentYear-1) >> date))!)

        case d(.Pascha)+7.days ... d(.EndOfYear):
            return String(format: Translate.s("Tone %@"), formatter.stringFromNumber(tone(dayNum: d(.Pascha) >> date))!)

        default: return nil
        }
    }

    static func getFastingDescription(date: NSDate) -> (FastingType, String) {

        setDate(date)
        
        switch date {
        case d(.Theophany),
        d(.MeetingOfLord):
            return (.NoFast, "No fast")
            
        case d(.NativityOfTheotokos),
        d(.PeterAndPaul),
        d(.Dormition),
        d(.Veil):
            return (currentWeekday == .Wednesday ||
                    currentWeekday == .Friday) ? (.FishAllowed, "Fish Allowed") : (.NoFast, "No fast")
            
        case d(.NativityOfJohn),
        d(.Transfiguration),
        d(.EntryIntoTemple),
        d(.StNicholas),
        d(.PalmSunday):
            return (.FishAllowed, "Fish Allowed")
            
        case d(.EveOfTheophany),
        d(.BeheadingOfJohn),
        d(.ExaltationOfCross):
            return (.Vegetarian, "Fast day")
            
        case d(.StartOfYear):
            return (currentWeekday == .Saturday ||
                    currentWeekday == .Sunday) ? (.FishAllowed, "Nativity Fast") : (.Vegetarian, "Nativity Fast")
            
        case d(.StartOfYear)+1.days ..< d(.NativityOfGod):
            return (.Vegetarian, "Nativity Fast")
            
        case d(.NativityOfGod) ..< d(.EveOfTheophany):
            return (.FastFree, "Svyatki")
            
        case d(.SundayOfPublicianAndPharisee)+1.days ... d(.SundayOfProdigalSon):
            return (.FastFree, "Fast-free week")
            
        case d(.SundayOfDreadJudgement)+1.days ..< d(.BeginningOfGreatLent):
            return (.Cheesefare, "Maslenitsa")
            
        case d(.BeginningOfGreatLent) ..< d(.PalmSunday):
            return (date == d(.Annunciation)) ? (.FishAllowed, "Fish allowed") : (.Vegetarian, "Great Lent")
            
        case d(.PalmSunday)+1.days ..< d(.Pascha):
            return (.Vegetarian, "Vegetarian")
            
        case d(.Pascha)+1.days ... d(.Pascha)+7.days:
            return (.FastFree, "Fast-free week")
            
        case d(.Pentecost)+1.days ... d(.Pentecost)+7.days:
            return (.FastFree, "Fast-free week")
            
        case d(.BeginningOfApostolesFast) ... d(.PeterAndPaul)-1.days:
            return (currentWeekday == .Monday ||
                    currentWeekday == .Wednesday ||
                    currentWeekday == .Friday) ? (.Vegetarian, "Apostoles' Fast") : (.FishAllowed, "Apostoles' Fast")
            
        case d(.BeginningOfDormitionFast) ... d(.Dormition)-1.days:
            return (.Vegetarian, "Dormition Fast")
            
        case d(.BeginningOfNativityFast) ..< d(.StNicholas):
            return (currentWeekday == .Monday ||
                    currentWeekday == .Wednesday ||
                    currentWeekday == .Friday) ? (.Vegetarian, "Nativity Fast") : (.FishAllowed, "Nativity Fast")
            
        case d(.StNicholas) ... d(.EndOfYear):
            return (currentWeekday == .Saturday ||
                    currentWeekday == .Sunday) ? (.FishAllowed, "Nativity Fast") : (.Vegetarian, "Nativity Fast")
            
        case d(.NativityOfGod) ..< d(.Pentecost)+8.days:
            return (currentWeekday == .Wednesday ||
                    currentWeekday == .Friday) ? (.FishAllowed, "Fish Allowed") : (.NoFast, "No fast")
            
        default:
            return (currentWeekday == .Wednesday ||
                    currentWeekday == .Friday) ? (.Vegetarian, "Vegetarian") : (.NoFast, "No fast")
        }
    }
}

typealias Cal = ChurchCalendar

