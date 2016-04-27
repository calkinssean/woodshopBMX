//
//  ItemsCollectionViewController.swift
//  M3rch
//
//  Created by Sean Calkins on 4/4/16.
//  Copyright © 2016 Sean Calkins. All rights reserved.
//

import UIKit

class ItemsCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    
    
    //MARK: - Properties
    var currentItem: Item?
    var arrayOfItems = [Item]()
    var searchResults = [Item]()
    var searchActive = false
    var currentEvent: Event?
    var numFormatter = NSNumberFormatter()
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(self.addTapped))
        
        numFormatter.minimumFractionDigits = 2
        numFormatter.maximumFractionDigits = 2
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Changes background image for woodshop or bike shop
        if let event = self.currentEvent {
            
            if event.name == "WoodShop" {
                
                self.imageView.image = UIImage(named: "wood copy")
            }
        }
        
        self.arrayOfItems = []
        
        //Grabs all items for the current event
        let fetchedItems = DataController.sharedInstance.fetchItems()
        
        for item in fetchedItems {
            
            if item.event == self.currentEvent {
                
                self.arrayOfItems.append(item)
                
            }
        }
        
        self.collectionView.reloadData()
        
    }
    
    //MARK: - View sales report tapped
    @IBAction func viewSalesReportTapped(sender: UIButton) {
        performSegueWithIdentifier("ShowSalesReportViewSegue", sender: self)
        
    }
    
    //MARK: - Add Tapped
    func addTapped() {
        performSegueWithIdentifier("showAddItemViewSegue", sender: self)
        
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(searchActive) {
            
            return searchResults.count
            
        }
        
        return arrayOfItems.count
    }
    
    // Configure the cell
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Item Cell", forIndexPath: indexPath) as! ItemCell
        
        cell.soldOutImage.hidden = true
        
        //If search is active, display search results
        if(searchActive) {
            
            let i = searchResults[indexPath.row]
            
            cell.itemNameLabel.text = i.name
            
            //Places "sold out" image over item picture if quantity is zero
            let quantity = Int(cell.getCurrentStock(i))
            
            cell.quantityLabel.text = ("\(quantity) left")
            
            //Places "sold out" image over item picture if quantity is zero
            if quantity == 0 {
                
                cell.soldOutImage.hidden = false
            }
            
            if let imageName = i.imageName {
                
                cell.loadImageFromUrl(imageName)
                
            }
            
            if let price = i.price {
                
                if let priceString = numFormatter.stringFromNumber(price) {
                    
                    cell.priceLabel.text = (" $\(priceString)")
                }
                
            }
            
            //Display regular items if search is not active
        } else {
            
            let i = arrayOfItems[indexPath.row]
            
            cell.itemNameLabel.text = i.name
            
            //Places "sold out" image over item picture if quantity is zero
            let quantity = Int(cell.getCurrentStock(i))
            
            cell.quantityLabel.text = ("\(quantity) left")
            
            if quantity == 0 {
                
                cell.soldOutImage.hidden = false
            }
            
            if let imageName = i.imageName {
                
                cell.loadImageFromUrl(imageName)
                
            }
            
            if let price = i.price {
                
                if let priceString = numFormatter.stringFromNumber(price) {
                    
                    cell.priceLabel.text = (" $\(priceString)")
                }
                
            }
            
        }
        
        return cell
        
    }
    
    //Use for size
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = self.view.frame.size
        return CGSizeMake(size.width / 2.022, size.width / 2.022)
    }
    //Use for interspacing
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    //MARK: - UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        //Sets the current item to selected item
        if(searchActive) {
            
            self.currentItem = searchResults[indexPath.row]
            
        } else {
            
            self.currentItem = arrayOfItems[indexPath.row]
            
        }
        
        performSegueWithIdentifier("ShowItemDetailViewSegue", sender: self)
        
    }
    
    //MARK: - Search Bar Delegate
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        
        searchActive = false
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        
        self.collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        //filters items on text did change
        filterItems(searchText)
        
       if(searchResults.count == 0) {
            
            searchActive = false
            
        } else {
            
            searchActive = true
            
        }
        
        self.collectionView.reloadData()
    }
    
    //MARK: - Filter method
    func filterItems(searchText: String) {
        
        self.searchResults = arrayOfItems.filter({
            
            (item: Item) -> Bool in
            
                //if item name in arrayOfItems matches search text put it in searchResults array
                let nameMatch = item.name?.rangeOfString(searchText, options: .CaseInsensitiveSearch)
                
                return nameMatch != nil
        
        })
        
    }
    
    //MARK: - Prepare for segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowItemDetailViewSegue" {
            let controller = segue.destinationViewController as! ItemDetailViewController
            
            controller.currentEvent = self.currentEvent
            
            if let item  = self.currentItem {
                controller.currentItem = item
            }
        }
        
        if segue.identifier == "showAddItemViewSegue" {
            let controller = segue.destinationViewController as! AddItemViewController
            controller.currentEvent = self.currentEvent
        }
        
        if segue.identifier == "ShowSalesReportViewSegue" {
            let controller = segue.destinationViewController as! SalesReportTableViewController
            controller.currentEvent = self.currentEvent
        }
    }
}
