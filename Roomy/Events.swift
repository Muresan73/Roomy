//
//  Events.swift
//  Roomy
//
//  Created by Darius on 2015. 04. 10..
//  Copyright (c) 2015. Darius. All rights reserved.
//

import Parse

class Events: PFObject, PFSubclassing {

    @NSManaged var title: String
    @NSManaged var date: NSDate
    @NSManaged var isUnread: NSNumber

    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    class func parseClassName() -> String {
        return "Events"
    }
}
