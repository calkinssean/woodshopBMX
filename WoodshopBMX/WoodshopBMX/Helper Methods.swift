//
//  Config.swift
//  M3rch
//
//  Created by Sean Calkins on 4/5/16.
//  Copyright © 2016 Sean Calkins. All rights reserved.
//

import UIKit

func getDocumentsDirectory() -> NSURL {
    
    return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    
}


func loadImageFromUrl(fileName: String) -> UIImage? {
    
    var image: UIImage?
    
    let filepath = getDocumentsDirectory().URLByAppendingPathComponent(fileName)
    
    if let pngData = NSData(contentsOfURL: filepath) {
        
            
            if let theImage = UIImage(data: pngData) {
                
                image = theImage
                
            }
        
    }
    return image
}

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




