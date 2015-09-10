//
//  ShoppingList.swift
//  Roomy
//
//  Created by Darius on 2015. 05. 19..
//  Copyright (c) 2015. Darius. All rights reserved.
//

import Foundation
import CoreData

class ShoppingList: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var cost: NSNumber
    @NSManaged var whoPaid: NSDecimalNumber
    @NSManaged var isPaid: NSNumber

}
