//
//  Event+CoreDataProperties.swift
//  M3rch
//
//  Created by Sean Calkins on 4/13/16.
//  Copyright © 2016 Sean Calkins. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Event {

    @NSManaged var name: String?
    @NSManaged var items: NSSet?
    @NSManaged var sales: NSSet?

}
