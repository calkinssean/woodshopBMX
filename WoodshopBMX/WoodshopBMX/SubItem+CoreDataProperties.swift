//
//  SubItem+CoreDataProperties.swift
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

extension SubItem {

    @NSManaged var color: String?
    @NSManaged var quantity: NSNumber?
    @NSManaged var size: String?
    @NSManaged var initialCost: NSNumber?
    @NSManaged var item: Item?
    @NSManaged var sales: Sale?

}
