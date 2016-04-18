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
        
        if let event = self.currentEvent {
            
            if event.name == "WoodShop" {
                
                self.imageView.image = UIImage(named: "wood copy")
            }
        }
        
        self.arrayOfItems = []
        
        let fetchedItems = DataController.sharedInstance.fetchItems()
        
        for item in fetchedItems {
            
            if item.event == self.currentEvent {
                
                self.arrayOfItems.append(item)
                
            }
        }
        
        self.collectionView.reloadData()
        
    }
    
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
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Item Cell", forIndexPath: indexPath) as! Item_Cell
        
        cell.soldOutImage.hidden = true
        //cell.backgroundColor = UIColor(red: 170, green: 170, blue: 170, alpha: 1)
        
        if(searchActive) {
            
            let i = searchResults[indexPath.row]
            
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
        print("did end")
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        
        self.collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        filterItems(searchText)
        
        print(searchActive)
        
        print(self.searchResults.count)
        
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
            
            for item in arrayOfItems {
                
                let nameMatch = item.name?.rangeOfString(searchText, options: .CaseInsensitiveSearch)
                
                return nameMatch != nil
                
            }
            
            return false
        })
        
    }
    
    //MARK: - Prepare for segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowItemDetailViewSegue" {
            let controller = segue.destinationViewController as! ItemDetailViewController
            
            controller.currentItem = self.currentItem!
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