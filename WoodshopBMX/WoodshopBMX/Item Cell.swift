//
//  Item Cell.swift
//  M3rch
//
//  Created by Sean Calkins on 4/4/16.
//  Copyright © 2016 Sean Calkins. All rights reserved.
//

import UIKit

class Item_Cell: UICollectionViewCell {
    
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var soldOutImage: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    
    func loadImageFromUrl(fileName: String) {
        
        let filepath = getDocumentsDirectory().URLByAppendingPathComponent(fileName)
        
        if let pngData = NSData(contentsOfURL: filepath) {
            
            if let theImage = UIImage(data: pngData) {
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.imageView.image = theImage
                    
                })
            }
        }
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
    
}
