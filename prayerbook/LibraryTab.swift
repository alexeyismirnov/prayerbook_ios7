//
//  LibraryTab.swift
//  ponomar
//
//  Created by Alexey Smirnov on 8/15/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

let books : [BookModel] = [BookmarksModel.shared,
                           OldTestamentModel.shared,
                           NewTestamentModel.shared]

class LibraryTab: UIViewController, ResizableTableViewCells  {
    let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BookmarksModel.books = books
        
        createTableView(style: .grouped)
        tableView.contentInset = UIEdgeInsets(top: -30, left: 0, bottom: 0, right: 0)
        
        navigationController?.makeTransparent()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTheme), name: .optionsSavedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTheme), name: .themeChangedNotification, object: nil)
        
        reloadTheme()
    }
    
    @objc func reloadTheme() {
        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(background: "bg3.jpg", inView: view, bundle: toolkit))
        }
        
        tableView.reloadData()
        title = Translate.s("Library")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getTextDetailsCell(title: books[indexPath.row].title, subtitle: "")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell : UITableViewCell = self.tableView(tableView, cellForRowAt: indexPath)
        return calculateHeightForCell(cell)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        navigationController?.pushViewController(BookTOC(books[indexPath.row])!, animated: true)
        return nil
    }
    
}
