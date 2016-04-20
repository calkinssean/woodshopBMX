//
//  ViewController.swift
//  M3rch
//
//  Created by Sean Calkins on 4/3/16.
//  Copyright © 2016 Sean Calkins. All rights reserved.
//

import UIKit

class TitleViewController: UIViewController {
    
    //MARK: - Properties
    var currentEvent: Event?
    var arrayOfEvents = [Event]()
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.seedEvents()
        
        self.arrayOfEvents = DataController.sharedInstance.fetchEvents()
    }
    
    //MARK: - Woodpile Tapped
    @IBAction func woodTapped(sender: UIButton) {
    
        for event in arrayOfEvents {
            
            if event.name == "WoodShop" {
                
                self.currentEvent = event
                
                performSegueWithIdentifier("showItemCollectionView", sender: self)
                
            }
        }
    }
    
    //MARK: - Bike tapped
    @IBAction func bikeTapped(sender: UIButton) {
        
        for event in arrayOfEvents {
            
            if event.name == "BikeShop" {
                
                self.currentEvent = event
                
                performSegueWithIdentifier("showItemCollectionView", sender: self)
                
            }
        }
    }

    //MARK: - Create Events
    func seedEvents() {
        
        if DataController.sharedInstance.fetchEvents().count < 2 {
            
            DataController.sharedInstance.seedEvent("BikeShop")
            DataController.sharedInstance.seedEvent("WoodShop")
            
        }
    }
    
    //MARK: - Prepare for segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showItemCollectionView" {
            
            let controller = segue.destinationViewController as! ItemsCollectionViewController
            
            controller.currentEvent = self.currentEvent
            
        }
    }
}

