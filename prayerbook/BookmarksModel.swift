//
//  BookmarksModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 5/12/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit

class BookmarksModel : BookModel {
    var code = "Bookmarks"
    var title = "Закладки..."
    var mode: BookType = .text

    var isExpandable = false
    var hasNavigation = false
    
    let prefs = UserDefaults(suiteName: groupId)!
    static let shared = BookmarksModel()

    
    func getSections() -> [String] {
        let bookmarks = prefs.stringArray(forKey: "bookmarks")!
        return (bookmarks.count == 0) ? [String]() : [""]
    }
    
    func getItems(_ section: Int) -> [String] {
        let bookmarks = prefs.stringArray(forKey: "bookmarks")!
        
        var arr = [String]()
        
        for b in bookmarks {
            let comp = b.components(separatedBy: "_")
            let model = books.filter() { $0.code == comp[0] }.first!
            
            arr.append(model.getBookmarkName(b))
        }

        return arr
    }

    func getNumChapters(_ index: IndexPath) -> Int { return 0 }
    
    func getComment(commentId: Int) -> String? { return nil }
    
    func resolveBookmarkAt(row: Int) -> BookPosition {
        let bookmarks = prefs.stringArray(forKey: "bookmarks")!
        let comp = bookmarks[row].components(separatedBy: "_")
        
        let model = books.filter() { $0.code == comp[0] }.first!
        let index = IndexPath(row: Int(comp[2])!, section: Int(comp[1])!)
        let chapter : Int = (comp.count == 4) ? Int(comp[3])! : 0
        
        return BookPosition(model: model, index: index, chapter: chapter)
    }
    
    func getContent(at pos: BookPosition) -> Any? { return nil }
        
    func getBookmark(at pos: BookPosition) -> String { return "" }
    
    func getBookmarkName(_ bookmark: String) -> String { return "" }
    
    func getNextSection(at pos: BookPosition) -> BookPosition? { return nil }
    
    func getPrevSection(at pos: BookPosition) -> BookPosition? { return nil }
    
}
