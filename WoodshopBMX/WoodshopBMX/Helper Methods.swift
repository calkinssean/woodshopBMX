//
//  Config.swift
//  M3rch
//
//  Created by Sean Calkins on 4/5/16.
//  Copyright © 2016 Sean Calkins. All rights reserved.
//

import UIKit

//MARK: - Get documents directory for device
func getDocumentsDirectory() -> NSURL {
    
    return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    
}

//MARK: - Load image from url
func loadImageFromUrl(fileName: String) -> UIImage? {
    
    var image: UIImage?
    
    let filepath = getDocumentsDirectory().URLByAppendingPathComponent(fileName)
    
    //if the filepath is NSData do this
    if let pngData = NSData(contentsOfURL: filepath) {
        
            //Convert NSData into an image
            if let theImage = UIImage(data: pngData) {
                
                image = theImage
                
            }
        
    }
    return image
}

//MARK: - Get current stock
func getCurrentStock(item: Item) -> Double {
    
    let fetchedSubItems = DataController.sharedInstance.fetchSubItems()
    
    var stockTotal: Double = 0
    
    for subItem in fetchedSubItems {
        
        if subItem.item == item {
            if let quantity = subItem.quantity {
                stockTotal = stockTotal + Double(quantity)
            }
        }
    }
    
    return stockTotal
}

//MARK: - Remove sub item
func removeSubItem() {
    
    let subItems = DataController.sharedInstance.fetchSubItems()
    
    //if any of the sub item quantities are 0, delete them
    for sItem in subItems {
        
        if let quan = sItem.quantity {
            
            if Double(quan) == 0 {
                
                DataController.sharedInstance.managedObjectContext.deleteObject(sItem)
                
                dataControllerSave()
                
            }
        }
    }
}

//MARK: - Data controller save
func dataControllerSave() {
    
    do {
        
        try DataController.sharedInstance.managedObjectContext.save()
        
    } catch {
        
        print("\(error)")
        
    }
    
}


