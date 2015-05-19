//
//  Chores.swift
//  Roomy
//
//  Created by Darius on 2015. 04. 10..
//  Copyright (c) 2015. Darius. All rights reserved.
//

import Parse

class Chores: PFObject, PFSubclassing {

    @NSManaged var title: String
    @NSManaged var whoDoneIt: PFUser
    @NSManaged var isDone: NSNumber

    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    class func parseClassName() -> String {
        return "Chores"
    }
    
}
