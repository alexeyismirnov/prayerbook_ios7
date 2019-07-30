//
//  DailyTab.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 27.03.15.
//  Copyright (c) 2015 Alexey Smirnov. All rights reserved.
//

import UIKit
import Squeal
import swift_toolkit

class DailyTab: UIViewControllerAnimated, ResizableTableViewCells, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var tableView: UITableView!
    
    let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")
    
    static let size15 = CGSize(width: 15, height: 15)
    static let icon15x15 : [FeastType: UIImage] = [
        .noSign: UIImage(named: "nosign")!.resize(size15),
        .sixVerse: UIImage(named: "sixverse")!.resize(size15),
        .doxology: UIImage(named: "doxology")!.resize(size15),
        .polyeleos: UIImage(named: "polyeleos")!.resize(size15),
        .vigil: UIImage(named: "vigil")!.resize(size15),
        .great: UIImage(named: "great")!.resize(size15)
    ]
    
    var appeared = false
    
    var fasting: FastingModel!
    var readings = [String]()
    
    var dayDescription = [(FeastType, String)]()
    var saints = [(FeastType, String)]()
    
    var currentDate: Date = {
        // this is done to remove time component from date
        return DateComponents(date: Date()).toDate()
    }()
    
    var formatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
    }()
    
    static var background : UIImage?
    
    static func date(_ date: Date) -> UIViewController {
        let vc = UIViewController.named("Daily") as! DailyTab
        vc.currentDate = date
        return vc
    }
    
    override func viewControllerCurrent() -> UIViewController {
        return DailyTab.date(currentDate)
    }
    
    override func viewControllerForward() -> UIViewController {
        return DailyTab.date(currentDate + 1.days)
    }
    
    override func viewControllerBackward() -> UIViewController {
        return DailyTab.date(currentDate - 1.days)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        automaticallyAdjustsScrollViewInsets = false

        configureNavbar()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(UINib(nibName: "TextCell", bundle: toolkit), forCellReuseIdentifier: "TextCell")
        tableView.register(UINib(nibName: "TextDetailsCell", bundle: toolkit), forCellReuseIdentifier: "TextDetailsCell")
        tableView.register(UINib(nibName: "ImageCell", bundle: toolkit), forCellReuseIdentifier: "ImageCell")

        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: NSNotification.Name(rawValue: optionsSavedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTheme), name: NSNotification.Name(rawValue: themeChangedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateDate), name: NSNotification.Name(rawValue: dateChangedNotification), object: nil)
        
        reloadTheme()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        appeared = true
        tableView.reloadData()
    }
    
    func hasTypica() -> Bool {
        if Translate.language != "cn" {
            return false
        }
        if (currentDate > Cal.d(.beginningOfGreatLent) && currentDate < Cal.d(.sunday2AfterPascha) || Cal.currentWeekday != .sunday) {
            return false
         
        } else {
            return true
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return dayDescription.count+2
            
        case 1:
            return 1
            
        case 2:
            return readings.count
            
        case 3:
            return hasTypica() ? 1 : 0
            
        case 4:
            return saints.count
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return ""
            
        case 1:
            return (FastingModel.fastingLevel == .monastic) ? Translate.s("Monastic fasting") : Translate.s("Laymen fasting")
            
        case 2:
            return readings.count > 0 ? Translate.s("Gospel of the day") : nil
            
        case 3:
            return hasTypica() ? Translate.s("Prayers") : nil
            
        case 4:
            return Translate.s("Memory of saints")
            
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let cell: TextDetailsCell = getCell()
                cell.title.text = formatter.string(from: currentDate).capitalizingFirstLetter()
                cell.subtitle.text = ""
                
                cell.title.textColor = Theme.textColor
                cell.subtitle.textColor = Theme.secondaryColor
                
                return cell
                
            case 1:
                let cell: TextCell = getCell()
                var descr = ""
                
                if let weekDescription = Cal.getWeekDescription(currentDate) {
                    descr = weekDescription
                }
                
                if let toneDescription = Cal.getToneDescription(currentDate) {
                    if descr.count > 0 {
                        descr += "; "
                    }
                    descr += toneDescription
                }
                
                return getTextCell(descr)
                
            default:
                let feast:FeastType = dayDescription[indexPath.row-2].0
                
                if feast == .none {
                    return getTextCell(dayDescription[indexPath.row-2].1)
                    
                } else if feast == .great {
                    let cell: ImageCell = getCell()
                    
                    cell.title.textColor = UIColor.red
                    cell.title.text = dayDescription[indexPath.row-2].1
                    cell.icon.image = UIImage(named: Cal.feastIcon[feast]!)
                    return cell
                    
                } else {
                    let cell: TextCell = getCell()
                    
                    let attachment = NSTextAttachment()
                    attachment.image = DailyTab.icon15x15[feast]
                    
                    let myString = NSMutableAttributedString(string: "")
                    myString.append(NSAttributedString(attachment: attachment))
                    
                    let dayString = dayDescription[indexPath.row-2].1
                    let day = dayString.colored(with: Theme.textColor)
                    myString.append(day)
                    
                    cell.title.attributedText = myString
                    
                    return cell
                }
            }
            
        } else if indexPath.section == 1 {
            let cell: ImageCell  = getCell()

            cell.title.attributedText = NSAttributedString(string: fasting.descr)
            cell.title.textColor =  Theme.textColor
            cell.icon.image = UIImage(named: "food-\(fasting.icon)", in: toolkit, compatibleWith: nil)
            cell.accessoryType =  .none
            
            return cell
            
        } else if indexPath.section == 2 {
            
            var title : String!
            var subtitle : String!
            
            switch indexPath.row {
            case 0 ..< readings.count:
                let currentReading = readings[indexPath.row].components(separatedBy: "#")
                
                title = Translate.readings(currentReading[0])
                if Translate.language == "cn" {
                    subtitle = ""
                } else {
                    subtitle = (currentReading.count > 1) ? Translate.s(currentReading[1].trimmingCharacters(in: CharacterSet.whitespaces)) : ""
                }
                
            default:
                title = ""
                subtitle=""
            }
            
            if appeared {
                let cell: TextDetailsCell = getCell()
                cell.accessoryType = .none
                
                cell.title.textColor = Theme.textColor
                cell.title.text = title
                cell.subtitle.text = subtitle
                cell.subtitle.textColor = Theme.secondaryColor
                
                return cell
                
            } else {
                let cell = getSimpleCell(title)
                cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
                
                return cell
            }
            
            
        } else if indexPath.section == 3 {
            let cell: TextDetailsCell = getCell()
            cell.title.textColor = Theme.textColor
            cell.title.text = Translate.s("Typica")
            cell.subtitle.text = ""
            
            return cell
            
        } else if indexPath.section == 4 {
            
            if saints[indexPath.row].0 == .none {
                if appeared {
                    return getTextCell(saints[indexPath.row].1)
                    
                } else {
                    return getSimpleCell(saints[indexPath.row].1)
                }
                
            } else {
                let attachment = NSTextAttachment()
                attachment.image = DailyTab.icon15x15[saints[indexPath.row].0]
                let attachmentString = NSAttributedString(attachment: attachment)
                
                let myString = NSMutableAttributedString(string: "")
                myString.append(attachmentString)
                
                let saintString = saints[indexPath.row].1
                let saint = saintString.colored(with: Theme.textColor)
               
                myString.append(saint)
                
                if appeared {
                    let cell: TextCell = getCell()
                    cell.title.attributedText = myString
                    return cell
                    
                } else {
                    let cell = getSimpleCell("")
                    cell.backgroundColor = UIColor.clear
                    cell.textLabel?.attributedText = myString
                    return cell
                    
                }
            }
        }
        
        let cell = getSimpleCell("")
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 2 {
            var vc : UIViewController!
            
            switch indexPath.row {
            case 0 ..< readings.count:
                let currentReading = readings[indexPath.row].components(separatedBy: "#")
                vc = UIViewController.named("Scripture")
                (vc as! Scripture).code = .pericope(currentReading[0])
                
            default:
                break
                
            }
            
            navigationController?.pushViewController(vc, animated: true)
            
        } else if indexPath.section == 3 {
            let prayer = UIViewController.named("Prayer") as! Prayer
            prayer.code = "typica"
            prayer.index = 0
            prayer.name = Translate.s("Typica")
            navigationController?.pushViewController(prayer, animated: true)
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (appeared) {
            let cell : UITableViewCell = self.tableView(tableView, cellForRowAt: indexPath)
            return calculateHeightForCell(cell)
            
        } else {
            switch (indexPath.section, indexPath.row) {
            case (0,0):
                return 35
                
            case (1,_), (2,_):
                return 35
                
            default:
                return 27
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.contentView.backgroundColor = UIColor.clear
        headerView.backgroundView?.backgroundColor = UIColor.clear
        headerView.textLabel?.textColor = Theme.secondaryColor
    }
    
    @objc func reloadTheme() {
        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            if DailyTab.background == nil {
                DailyTab.background = UIImage(background: "bg3.jpg", inView: view, bundle: toolkit)
            }
   
            view.backgroundColor = UIColor(patternImage: DailyTab.background!)
        }
        
        reload()
    }
    
    @objc func reload() {
        formatter.locale = Translate.locale
        
        dayDescription = Cal.getDayDescription(currentDate)
        fasting = FastingModel.fasting(forDate: currentDate)
        
        saints = SaintModel.saints(self.currentDate)
        readings = DailyReading.getDailyReading(currentDate)
        
        tableView.reloadData()
    }
    
    func configureNavbar() {
        navigationController?.makeTransparent()
        
        let button_monthly = UIBarButtonItem(image: UIImage(named: "calendar"), style: .plain, target: self, action: #selector(showMonthlyCalendar))
        let button_widget = UIBarButtonItem(image: UIImage(named: "question"), style: .plain, target: self, action: #selector(showTutorial))
        let button_options = UIBarButtonItem(image: UIImage(named: "options"), style: .plain, target: self, action: #selector(showOptions))
        
        button_widget.imageInsets = UIEdgeInsets.init(top: 0,left: 0,bottom: 0,right: -20)
        
        navigationItem.leftBarButtonItems = [button_monthly]
        navigationItem.rightBarButtonItems = [button_options, button_widget]
    }
    
    @objc func showMonthlyCalendar() {
       /*
        var width, height : CGFloat
        
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            width = 300
            height = 350
            
        } else {
            width = 500
            height = 530
        }
        
        let container = UIViewController.named("CalendarContainer") as! UINavigationController
        container.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        container.navigationBar.barTintColor = UIColor(hex: "#FFEBCD")
        container.navigationBar.tintColor = .blue
        container.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.foregroundColor.rawValue : UIColor.black])

        modalSheet = NAModalSheet(viewController: container, presentationStyle: .fadeInCentered)
        
        modalSheet.disableBlurredBackground = true
        modalSheet.cornerRadiusWhenCentered = 10
        modalSheet.delegate = self
        modalSheet.adjustContentSize(CGSize(width: width, height: height), animated: false)
        
        modalSheet.present(completion: {})
 */
    }
        
    @objc func updateDate(_ notification: NSNotification) {
        /*
        modalSheet.dismiss(completion: {
        })
        */
        
        if let newDate = notification.userInfo?["date"] as? Date {
            currentDate = newDate
            reload()
            tableView.setContentOffset(CGPoint.zero, animated: false)
        }
    }
    
    @objc func showTutorial() {
        let vc = UIViewController.named("Tutorial") as! Tutorial
        let nav = UINavigationController(rootViewController: vc)
        vc.delegate = self
        
        navigationController?.present(nav, animated: true, completion: {})
    }
    
    @objc func showOptions() {
        let vc = UIViewController.named("Options") as! Options
        let nav = UINavigationController(rootViewController: vc)
        navigationController?.present(nav, animated: true, completion: {})
    }
    
}
