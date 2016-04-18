//
//  Sale+CoreDataProperties.swift
//  M3rch
//
//  Created by Sean Calkins on 4/14/16.
//  Copyright © 2016 Sean Calkins. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Sale {

    @NSManaged var amount: NSNumber?
    @NSManaged var created: NSDate?
    @NSManaged var type: String?
    @NSManaged var initialCost: NSNumber?
    @NSManaged var event: Event?
    @NSManaged var item: Item?
    @NSManaged var subItem: SubItem?

}
