//
//  ItemDetailViewController.swift
//  M3rch
//
//  Created by Sean Calkins on 4/4/16.
//  Copyright © 2016 Sean Calkins. All rights reserved.
//

import UIKit
import Charts

class ItemDetailViewController: UIViewController, ChartViewDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var itemQuantityLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var colorButtons: [UIButton]!
    @IBOutlet var sizeButtons: [UIButton]!
    @IBOutlet weak var currentSizeLabel: UILabel!
    @IBOutlet weak var currentColorView: UIView!
    @IBOutlet weak var pickColorLabel: UILabel!
    
    //MARK: - Properties
    var currentItem: Item?
    var currentSubItem: SubItem?
    var currentColor: String?
    var currentSize: String?
    var formatter = NSDateFormatter()
    var timeInterval: Double = 3600
    var arrayOfSubItems = [SubItem]()
    var sizeStrings = [String]()
    var numFormatter = NSNumberFormatter()
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.currentItem?.name
        
        numFormatter.minimumFractionDigits = 2
        numFormatter.maximumFractionDigits = 2
        
        self.updateUI()
        
        //Grab subitems for current item from data store
        let fetchedSubItems = DataController.sharedInstance.fetchSubItems()
        
        for subItem in fetchedSubItems {
            
            if subItem.item == self.currentItem {
                
                self.arrayOfSubItems.append(subItem)
            }
        }
        
        self.changeSizeButtonTitles()
        self.updateColorButtons()
        self.updateSizeButtons()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit Item", style: .Plain, target: self, action: #selector(self.editItemTapped))
        
        formatter.dateFormat = "h:mm a"
        formatter.AMSymbol = "AM"
        formatter.PMSymbol = "PM"
        
    }
    
    //MARK: - Color button tapped
    @IBAction func colorButtons(sender: UIButton) {
        
        if let color = sender.backgroundColor {
            
            self.currentColor = "\(color)"
            self.currentColorView.backgroundColor = color
            self.pickColorLabel.text = "Pick a Size"
            
        }
        
        var stock: Int = 0
        for item in arrayOfSubItems {
            if item.color == self.currentColor {
                if let quan = item.quantity {
                    stock = stock + Int(quan)
                    self.itemQuantityLabel.text = "\(stock) left"
                }
            }
        }
        
        self.updateSizeButtons()
        
    }
    
    //MARK: - Size button tapped
    @IBAction func sizeButtons(sender: UIButton) {
        
        if let size = sender.titleLabel?.text {
            
            self.currentSize = size
            self.currentSizeLabel.text = size
            self.pickColorLabel.text = ""
            
        }
        
        for item in arrayOfSubItems {
            
            if item.color == self.currentColor && item.size == self.currentSize {
                
                self.currentSubItem = item
                
                if let quan = (item.quantity) {
                    
                    self.itemQuantityLabel.text = "\(Int(quan)) left"
                    
                }
            }
        }
    }
    
    //MARK: - Sell item tapped
    @IBAction func sellItemTapped() {
        
        if self.currentColor != nil && self.currentSize != nil {
            
            if let quan = self.currentSubItem?.quantity {
                
                if Double(quan) > 0 {
                    
                    self.saleTypeAlert()
                    
                } else {
                    
                    self.presentAlert("Item is sold out")
                }
                
            } else {
                
                self.presentAlert("Please select a size and color")
            }
            
        } else {
            
            self.presentAlert("Please select a size and color")
        }
    }
    
    //Alert if item is sold out
    func presentAlert(message: String) {
        
        let alert = UIAlertController(title: "\(message)", message: nil, preferredStyle: .Alert)
        let ok = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(ok)
        
        presentViewController(alert,
                              animated: true,
                              completion: nil)
        
        self.updateColorButtons()
        self.updateSizeButtons()
        
    }
    
    //Choose type of sale
    func saleTypeAlert() {
        
        let alert = UIAlertController(title: "Sell Item",
                                      message: "Choose Type Of Sale",
                                      preferredStyle: .Alert)
        
        //If cash sale, create sale object with "Cash" as type
        let cashAction = UIAlertAction(title: "Cash", style: .Default) { (action: UIAlertAction) -> Void in
            
            if let quan = self.currentSubItem?.quantity {
                
                if Double(quan) > 0 {
                    
                    var newAmount = Double(quan)
                    
                    newAmount = newAmount - Double(1)
                    
                    self.currentSubItem?.setValue(newAmount, forKey: "quantity")
                    
                    self.save()
                    
                    let date = NSDate()
                    
                    if let price = self.currentItem?.price {
                        
                        let priceDouble = Double(price)
                        
                        if let event = self.currentItem?.event {
                            
                            if let item = self.currentItem {
                                
                                if let currentSubItem = self.currentSubItem {
                                    
                                    if let initialCost = self.currentItem?.purchasedPrice {
                                        
                                        DataController.sharedInstance.seedSale(date, type: "Cash", amount: priceDouble, initialCost: Double(initialCost), event: event, item: item, subItem: currentSubItem)
                                   
                                    }
                                }
                            }
                        }
                    }
                } else {
                    self.presentAlert("Item is sold out")
                }
            }
            
            for item in self.arrayOfSubItems {
                
                if item.color == self.currentColor && item.size == self.currentSize {
                    
                    self.currentSubItem = item
                    
                    if let quan = item.quantity {
                        
                        self.itemQuantityLabel.text = "\(Int(quan)) left"
                    }
                }
            }
        }
        
        //If cash sale, create sale object with "Card" as type
        let cardAction = UIAlertAction(title: "Card", style: .Default) { (action: UIAlertAction) -> Void in
            
            if let quan = self.currentSubItem?.quantity {
                
                if Double(quan) > 0 {
                    
                    var newAmount = Double(quan)
                    
                    newAmount = newAmount - Double(1)
                    
                    self.currentSubItem?.setValue(newAmount, forKey: "quantity")
                    
                    self.save()
                    
                    let date = NSDate()
                    
                    if let price = self.currentItem?.price {
                        
                        let priceDouble = Double(price)
                        
                        if let event = self.currentItem?.event {
                            
                            if let item = self.currentItem {
                                
                                if let currentSubItem = self.currentSubItem {
                                    
                                    if let initialCost = self.currentItem?.purchasedPrice {
                                        
                                        DataController.sharedInstance.seedSale(date, type: "Card", amount: priceDouble, initialCost: Double(initialCost), event: event, item: item, subItem: currentSubItem)
                                        
                                    }
                                }
                            }
                        }
                    }
                    
                } else {
                    
                    self.presentAlert("Item is sold out")
                }
            }
           
            self.updateUI()
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action: UIAlertAction) -> Void in
            
        }
        
        alert.addAction(cashAction)
        alert.addAction(cardAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert,
                              animated: true,
                              completion: nil)
    }
    
    //MARK: - Helper Methods
    func updateUI() {
        
        if let price = self.currentItem?.price {
            
            if let formattedString = numFormatter.stringFromNumber(price) {
                
                self.itemPriceLabel.text = "$\(formattedString)"
                
            }
        }
        
        let qty = Int(self.getCurrentStock(self.currentItem!))
        self.itemQuantityLabel.text = "\(qty) left"
        
        if let imageName = currentItem?.imageName {
            
            if let image = loadImageFromUrl(imageName) {
                
                self.imageView.image = image
                
            }
        }
        
        self.currentSize = nil
        self.currentColor = nil
        self.currentSizeLabel.text = ""
        self.currentColorView.backgroundColor = UIColor.clearColor()
        self.pickColorLabel.text = "Pick a Color"
        
    }
    
    
    //MARK: - Change size button titles
    func changeSizeButtonTitles() {
        
        for item in arrayOfSubItems {
            
            if !self.sizeStrings.contains(item.size!) {
                
                self.sizeStrings.append(item.size!)
                
            }
        }
        
        for (index, size) in self.sizeStrings.enumerate() {
            
            let button = self.sizeButtons[index]
            
            button.setTitle(size, forState: .Normal)
            
            button.hidden = false
        }
    }
    
    //MARK: - Edit Item Tapped
    func editItemTapped() {
        performSegueWithIdentifier("editItemSegue", sender: self)
    }
    
    //MARK: - Prepare for segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "editItemSegue" {
            
            let controller = segue.destinationViewController as! ColorsAndSizesViewController
            
            controller.currentItem = self.currentItem
        }
    }
    
    //MARK: - Update Color Buttons
    func updateColorButtons() {
        
        for button in colorButtons {
            
            button.hidden = true
            
        }
        
        for sItem in arrayOfSubItems {
            
            if let quan = sItem.quantity {
                
                if Double(quan) > 0 {
                    
                    for button in colorButtons {
                        
                        if let color = button.backgroundColor {
                            
                            if "\(color)" == sItem.color {
                                
                                button.hidden = false
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Update size buttons
    func updateSizeButtons() {
        
        for button in sizeButtons {
            
            button.hidden = true
            
        }
        
        for sItem in arrayOfSubItems {
            
            if let quan = sItem.quantity {
                
                if Double(quan) > 0 {
                    
                    for button in sizeButtons {
                        
                        if let color = sItem.color {
                            
                            if let size = button.titleLabel!.text {
                                
                                if size == sItem.size && color == self.currentColor {
                                    
                                    button.hidden = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Unwind Segue
    @IBAction func unwindSegue (segue: UIStoryboardSegue) {}
    
    //Add the quantities of all sub items to get a quantity of current item
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
    
    func save() {
        
        
        do {
            
            try DataController.sharedInstance.managedObjectContext.save()
            
        } catch {
            
            print("\(error)")
            
        }
    }
    
}
