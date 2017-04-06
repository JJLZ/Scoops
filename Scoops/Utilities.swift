//
//  Utilities.swift
//  Scoops
//
//  Created by JJLZ on 4/7/17.
//  Copyright © 2017 ESoft. All rights reserved.
//

import Foundation

func getAuthor(fromUser user: FIRUser?) -> String {
    
    if let currentUser = user
    {
        return currentUser.displayName!
    }
    
    return ""
}

func getUserId(fromUser user: FIRUser?) -> String {
    
    if let currentUser = user
    {
        return currentUser.uid
    }
    
    return ""
}

