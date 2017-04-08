//
//  Utilities.swift
//  Scoops
//
//  Created by JJLZ on 4/7/17.
//  Copyright © 2017 ESoft. All rights reserved.
//

import Foundation
import GoogleSignIn

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

func makeLogout()
{
    if  let _ = FIRAuth.auth()?.currentUser {
        do {
            try FIRAuth.auth()?.signOut()
            GIDSignIn.sharedInstance().signOut()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
