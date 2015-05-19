//
//  Roommates.swift
//  Roomy
//
//  Created by Darius on 2015. 04. 10..
//  Copyright (c) 2015. Darius. All rights reserved.
//

import Parse

class Roommates: PFObject, PFSubclassing   {

    @NSManaged var id: NSNumber
    @NSManaged var name: String
    @NSManaged var user: PFUser

    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    class func parseClassName() -> String {
        return "Roommates"
    }
}
