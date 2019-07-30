//
//  AppDelegate.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/5/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit
import Chameleon
import swift_toolkit

class AppDelegate : UIResponder, UIApplicationDelegate {
    var window: UIWindow?
   
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var openDate: Date
        
        if url.scheme == "ponomar" {
            openDate = Date(timeIntervalSince1970: Double(url.query!)!)
            
            if let root = window?.rootViewController as? MainVC,
                let controllers = root.viewControllers,
                let nav = controllers[0] as? UINavigationController,
                let vc = nav.topViewController as? DailyTab{
                root.selectedIndex = 0
                vc.currentDate = openDate
                
                if vc.isViewLoaded {
                    vc.reload()
                }
            }
            
            return true
            
        }  else {
            return false
        }
        
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppGroup.id = "group.rlc.ponomar"
        let prefs = AppGroup.prefs!
        
        if prefs.object(forKey: "theme") == nil {
            Theme.set(.Default)
            
        } else {
            let color = prefs.color(forKey: "theme")
            Theme.set(.Chameleon(color: color!))
        }
        
        // the first time app is launched
        if prefs.object(forKey: "fontSize") == nil {
            let lang = Locale.preferredLanguages[0]

            if (lang.hasPrefix("zh-Hans") || lang.hasPrefix("zh-Hant")) {
                prefs.set("cn", forKey: "language")
            } else {
                prefs.set("en", forKey: "language")
            }
            
            if (UIDevice.current.userInterfaceIdiom == .phone) {
                prefs.set(20, forKey: "fontSize")
            } else {
                prefs.set(22, forKey: "fontSize")
            }
        }
        
        if prefs.object(forKey: "fastingLevel") == nil {
            prefs.set(0, forKey: "fastingLevel")
        }
        
        prefs.synchronize()
        
        FastingModel.fastingLevel = FastingLevel(rawValue: prefs.integer(forKey: "fastingLevel"))

        setupFiles()
        
        Translate.files = ["trans_ui_cn", "trans_cal_cn", "trans_library_cn"]
        Translate.language = prefs.object(forKey: "language") as! String
        
        return true
    }
    
    func setupFiles() {
        for lang in ["en", "cn"] {
            for month in 1...12 {
                let filename = String(format: "saints_%02d_%@", month, lang)
                AppGroup.copyFile(filename, "sqlite")
            }
        }
        
        AppGroup.copyFile("trans_ui_cn", "plist")
        AppGroup.copyFile("trans_cal_cn", "plist")
        AppGroup.copyFile("trans_library_cn", "plist")
    }
    
}
