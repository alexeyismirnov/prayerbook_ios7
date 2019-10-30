//
//  TroparionModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 11/9/18.
//  Copyright © 2018 Alexey Smirnov. All rights reserved.
//

import Foundation
import Squeal
import swift_toolkit

struct Troparion {
    var title : String
    var content : String
    var url : String?
    
    init(title : String, content : String, url : String? = nil) {
        self.title = title
        self.content = content
        self.url = url
    }
}

protocol TroparionModel {
    var url : String { get }
    var fileSize : Int { get }
    var title : String { get }

    func isDownloaded() -> Bool
    func isAvailable(on date : Date) -> Bool
    func getTroparion(for date : Date) -> [Troparion]
}

class TroparionFeastModel : TroparionModel {
    var title = "Тропарь и кондак праздника"
    var url = "https://filedn.com/lUdNcEH0czFSe8uSnCeo29F/prayerbook/tropari.zip"
    var fileSize = 22

    var path:String!

    static let shared = TroparionFeastModel()
    
    init() {
        let documentDirectory:URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        path = documentDirectory.path + "/tropari/tropari/tropari.sqlite"
    }
    
    func isAvailable(on date : Date) -> Bool {
        return Cal.getGreatFeast(date) != nil
    }

    func getTroparion(for date : Date) -> [Troparion]  {
        let code = Cal.getGreatFeast(date)!
        let db = try! Database(path:path)
        
        var troparion = [Troparion]()

        let results = try! db.selectFrom("tropari", whereExpr:"code=\(code.rawValue)", orderBy: "id") { ["title": $0["title"], "content": $0["content"], "url": $0["url"]]}
        
        for line in results {
            let title = line["title"] as! String
            let content =  line["content"] as! String
            let url = line["url"] as? String
            
            troparion.append(Troparion(title: title, content: content, url: url != nil ? "/tropari/tropari/\(url!).mp3" : nil))
        }
        
        return troparion
    }
    
    func isDownloaded() -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
}

class TroparionDayModel : TroparionModel {
    var title : String {
        get {
            if Cal.d(.pascha) ..< Cal.d(.sunday2AfterPascha) ~= Cal.currentDate {
                return "Часы пасхальные"
            } else {
                return "Тропарь и кондак дня"
            }
        }
    }
    
    var url = "https://filedn.com/lUdNcEH0czFSe8uSnCeo29F/prayerbook/tropari_day.zip"
    var fileSize = 20
    
    var path:String!

    static let shared = TroparionDayModel()
    
    init() {
        let documentDirectory:URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        path = documentDirectory.path + "/tropari_day/tropari_day/tropari_day.sqlite"
    }
    
    func isAvailable(on date : Date) -> Bool {
        if Cal.d(.palmSunday) ... Cal.d(.pascha)  ~= date {
            return false
            
        } else {
            return Cal.getGreatFeast(date) == nil
        }
    }
    
    func getTroparion(for date : Date) -> [Troparion]  {
        var troparion = [Troparion]()
        let db = try! Database(path:path)

        var code: Int = 0
        let dateComponents = DateComponents(date: date)

        if Cal.d(.pascha) ..< Cal.d(.sunday2AfterPascha) ~= date {
            code = 100
            
        } else if dateComponents.weekday! == 1 {
            code = 10 + Cal.getTone(date)!
            
        } else {
            code = dateComponents.weekday!
        }
        
        let results = try! db.selectFrom("tropari", whereExpr:"code=\(code)", orderBy: "id") { ["title": $0["title"], "content": $0["content"], "url": $0["url"]]}
        
        for line in results {
            let title = line["title"] as! String
            let content =  line["content"] as! String
            let url = line["url"] as? String
            
            troparion.append(Troparion(title: title, content: content, url: url != nil ? "/tropari_day/tropari_day/\(url!).mp3" : nil))
        }
        
        return troparion
    }
    
    func isDownloaded() -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
}

