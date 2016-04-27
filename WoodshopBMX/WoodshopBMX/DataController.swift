//
//  DataController.swift
//  M3rch
//
//  Created by Sean Calkins on 4/4/16.
//  Copyright © 2016 Sean Calkins. All rights reserved.
//

import Foundation
import CoreData

class DataController: NSObject {
    
    var managedObjectContext: NSManagedObjectContext
    
    static let sharedInstance = DataController()
    
    override init() {
        
        //This is the url for my models
        guard let modelURL = NSBundle.mainBundle().URLForResource("M3rch", withExtension:"momd") else {
            
            fatalError("Error loading model from bundle")
            
        }
        
        //Managed object document, fatal error if it can't be loaded
        guard let mom = NSManagedObjectModel(contentsOfURL: modelURL) else {
            
            fatalError("Error initializing mom from: \(modelURL)")
            
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        
        self.managedObjectContext.persistentStoreCoordinator = psc
        
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
        let docURL = urls[urls.endIndex - 1]
        
        let storeUrl = docURL.URLByAppendingPathComponent("M3rch.sqlite")
        
        do {
            
            try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeUrl, options: nil)
            
        } catch {
            
            fatalError("Error migrating store: \(error)")
            
        }
    }
    
    
    //MARK: - Seed Event
    func seedEvent(eventName: String) -> Bool {
        
        let eventEntity = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: managedObjectContext) as! Event
        
        eventEntity.setValue(eventName, forKey: "name")
        
        do {
            try managedObjectContext.save()
        
            return true
            
        } catch {
            
            fatalError("failure to save context \(error)")
        }
        return false
        
    }
    
    //MARK: - Seed Item
    func seedItem(name: String, price: Double, purchasedPrice: Double, imageName: String, event: Event) -> Bool {
        
        let itemEntity = NSEntityDescription.insertNewObjectForEntityForName("Item", inManagedObjectContext: managedObjectContext) as! Item
        
        itemEntity.setValue(name, forKey: "name")
        itemEntity.setValue(price, forKey: "price")
        itemEntity.setValue(imageName, forKey: "imageName")
        itemEntity.setValue(event, forKey: "event")
        itemEntity.setValue(purchasedPrice, forKey: "purchasedPrice")
        
        do {
            try managedObjectContext.save()
            
            return true
            
        } catch {
            
            fatalError("failure to save context \(error)")
        }
        return false
        
    }
    
    //MARK: - Seed Sub Item
    func seedSubItem(initialCost: Double, quantity: Double, color: String, size: String, item: Item) -> Bool {
        
        let itemEntity = NSEntityDescription.insertNewObjectForEntityForName("SubItem", inManagedObjectContext: managedObjectContext) as! SubItem
        
        itemEntity.setValue(initialCost, forKey: "initialCost")
        itemEntity.setValue(quantity, forKey: "quantity")
        itemEntity.setValue(color, forKey: "color")
        itemEntity.setValue(size, forKey: "size")
        itemEntity.setValue(item, forKey: "item")
        
        do {
            
            try managedObjectContext.save()
           
            return true
            
        } catch {
            
            fatalError("failure to save context \(error)")
            
        }
        return false
    }
    
    //MARK: - Seed Sale
    func seedSale(created: NSDate, type: String, amount: Double, initialCost: Double, event: Event, item: Item, subItem: SubItem) -> Bool {
        
        let itemEntity = NSEntityDescription.insertNewObjectForEntityForName("Sale", inManagedObjectContext: managedObjectContext) as! Sale
        
        itemEntity.setValue(created, forKey: "created")
        itemEntity.setValue(type, forKey: "type")
        itemEntity.setValue(amount, forKey: "amount")
        itemEntity.setValue(initialCost, forKey: "initialCost")
        itemEntity.setValue(event, forKey: "event")
        itemEntity.setValue(item, forKey: "item")
        
        do {
            try managedObjectContext.save()
            
            return true
            
        } catch {
            
            fatalError("failure to save context \(error)")
        }
       return false
        
    }
    
    //MARK: - Fetch Events
    func fetchEvents() -> [Event] {
        
        let fetchEvent = NSFetchRequest(entityName: "Event")
        
        do {
            
            let fetchedEvents = try managedObjectContext.executeFetchRequest(fetchEvent) as! [Event]
            
            return fetchedEvents
            
        } catch {
            
            fatalError("failure to fetch events \(error)")
            
        }
        
    }
    
    //MARK: - Fetch Items
    func fetchItems() -> [Item] {
        
        let fetchItem = NSFetchRequest(entityName: "Item")
        
        do {
            
            let fetchedItems = try managedObjectContext.executeFetchRequest(fetchItem) as! [Item]
            
            return fetchedItems
            
        } catch {
            
            fatalError("failed to fetch items \(error)")
            
        }
    }
    
    //MARK: - Fetch SubItems
    func fetchSubItems() -> [SubItem] {
        
        let fetchSubItem = NSFetchRequest(entityName: "SubItem")
        
        do {
            
            let fetchedSubItems = try managedObjectContext.executeFetchRequest(fetchSubItem) as! [SubItem]
            
            return fetchedSubItems
            
        } catch {
            
            fatalError("failed to fetch subitems \(error)")
            
        }
    }
    
    //MARK: - Fetch Sales
    func fetchSales() -> [Sale] {
        
        let fetchSale = NSFetchRequest(entityName: "Sale")
        
        do {
            
            let fetchedSales = try managedObjectContext.executeFetchRequest(fetchSale) as! [Sale]
            
            return fetchedSales
            
        } catch {
            
            fatalError("failed to fetch items \(error)")
            
        }
    }
    
}
