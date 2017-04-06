//
//  News.swift
//  Scoops
//
//  Created by JJLZ on 4/5/17.
//  Copyright © 2017 ESoft. All rights reserved.
//

import UIKit

class New: NSObject {
    
    var title: String
    var text: String
    var author: String
    var isPublished: Bool
    var refInCloud: FIRDatabaseReference?
    
    init(title: String, text: String, author: String, isPublished: Bool)
    {
        self.title = title
        self.text = text
        self.author = author
        self.isPublished = isPublished
        
        self.refInCloud = nil
    }
    
    init(snapshot: FIRDataSnapshot?) {
        
        refInCloud = snapshot?.ref
        
        title = (snapshot?.value as? [String: Any])?["title"] as! String
        text = (snapshot?.value as? [String: Any])?["text"] as! String
        author = (snapshot?.value as? [String: Any])?["author"] as! String
        isPublished = (snapshot?.value as? [String: Any])?["isPublished"] as! Bool
    }
}
