//
//  EventsTableViewController.swift
//  M3rch
//
//  Created by Sean Calkins on 4/4/16.
//  Copyright © 2016 Sean Calkins. All rights reserved.
//

import UIKit

class EventsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var arrayOfEvents = [Event]()
    var currentEvent: Event?
    var formatter = NSDateFormatter()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.backgroundColor = UIColor(red: 170, green: 170, blue: 170, alpha: 0.5)
        
        
        formatter.dateFormat = "MM/dd/yyyy hh:mm"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(self.addTapped))
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.arrayOfEvents = []
        
        self.arrayOfEvents = DataController.sharedInstance.fetchEvents()
        self.tableView.reloadData()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        

    }
    
    func addTapped() {

        performSegueWithIdentifier("showNewEventViewSegue", sender: self)
    
    }

    //MARK: - Table View Data Source
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrayOfEvents.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let e = arrayOfEvents[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("Event Cell", forIndexPath: indexPath)
        cell.textLabel?.text = e.name
        cell.textLabel?.textColor = UIColor.blackColor()
        cell.textLabel?.shadowOffset = CGSizeMake(-1, -1)
        cell.textLabel?.shadowColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor(red: 170, green: 170, blue: 170, alpha: 0.2)
        
        cell.textLabel?.font = UIFont(name: "Avenir Next", size: 30)
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showItemsCollectionViewSegue" {
            
            let controller = segue.destinationViewController as! ItemsCollectionViewController
            
            controller.currentEvent = self.currentEvent
            
        }
    }
    
    //MARK: - Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
//        self.currentEvent = arrayOfEvents[indexPath.row]
//        print(formatter.stringFromDate((currentEvent?.startDate)!), formatter.stringFromDate((currentEvent?.endDate)!))
//        performSegueWithIdentifier("showItemsCollectionViewSegue", sender: self)
    }

}
