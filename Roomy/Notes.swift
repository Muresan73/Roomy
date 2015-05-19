//
//  Notes.swift
//  Roomy
//
//  Created by Darius on 2015. 04. 10..
//  Copyright (c) 2015. Darius. All rights reserved.
//

import Parse

class Notes: PFObject, PFSubclassing  {

    @NSManaged var note: String
    @NSManaged var sender: String
    @NSManaged var recordAge: NSNumber
    @NSManaged var isUnread: NSNumber
    
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    class func parseClassName() -> String {
        return "Notes"
    }

}
