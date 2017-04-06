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
    
    init(title: String, text: String, author: String, isPublished: Bool)
    {
        self.title = title
        self.text = text
        self.author = author
        self.isPublished = isPublished
    }
    
}
