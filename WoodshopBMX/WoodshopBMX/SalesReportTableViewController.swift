//
//  NewEventViewController.swift
//  M3rch
//
//  Created by Sean Calkins on 4/4/16.
//  Copyright © 2016 Sean Calkins. All rights reserved.
//

import UIKit
import Charts
import MessageUI

class SalesReportTableViewController: UITableViewController, UITextFieldDelegate,  MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var totalSalesLabel: UILabel!
    @IBOutlet weak var cashTotalLabel: UILabel!
    @IBOutlet weak var cardTotalLabel: UILabel!
    @IBOutlet weak var profitLabel: UILabel!
    @IBOutlet weak var inventoryTotalLabel: UILabel!
    
    var formatter = NSDateFormatter()
    var numFormatter = NSNumberFormatter()
    var startDatePickerHidden = true
    var endDatePickerHidden = true
    var arrayOfSales = [Sale]()
    var salesForSearchedDay = [Sale]()
    var currentEvent: Event?
    var timeStrings = [String]()
    var salesDoubles = [Double]()
    var imageData: NSData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchedSales = DataController.sharedInstance.fetchSales()
        
        for sale in fetchedSales {
            
            if sale.event == self.currentEvent {
                
                self.arrayOfSales.append(sale)
                
            }
        }
        
        numFormatter.minimumFractionDigits = 2
        numFormatter.maximumFractionDigits = 2
        datePickerChanged()
        calculateInventoryTotal()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(self.saveEmailTapped))
        
    }
    
    //MARK: - Date picker value changed
    @IBAction func datePickerValue(sender: UIDatePicker) {
        
        datePickerChanged()
        
    }
    
    //MARK: - Date picker changed
    func datePickerChanged () {
        
        self.salesForSearchedDay = []
        let string = formatter.stringFromDate(getStartOfDay(startDatePicker.date))
        formatter.dateFormat = "MM/dd/yyyy"
        startDateLabel.text = string
        setUpXAxis(getStartOfDay(startDatePicker.date).timeIntervalSince1970)
        for sale in arrayOfSales {
            if let created = sale.created {
                if self.isWithinIntervals(getStartOfDay(startDatePicker.date), createdDate: created, timeInterval: 86400) {
                    self.salesForSearchedDay.append(sale)
                }
            }
        }
        self.calculateSalesForTheDay()
        
    }
    
    //MARK: - Tableview Delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 1 {
            toggleStartDatePicker()
        }
        
    }
    
    func toggleStartDatePicker() {
        
        startDatePickerHidden = !startDatePickerHidden
        
        tableView.beginUpdates()
        tableView.endUpdates()
        
    }
    
    //MARK: - Tableview Datasource
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if startDatePickerHidden && indexPath.section == 0 && indexPath.row == 2 {
            
            return 0
            
        } else {
            
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0.00000000001
    }
    
    //MARK: - Inventory Total Calculation
    func calculateInventoryTotal() {
        var inventoryTotal: Double = 0
        var arrayOfItems = [Item]()
        
        let arrayOfFetchItems = DataController.sharedInstance.fetchItems()
        let arrayOfFetchedSubItems = DataController.sharedInstance.fetchSubItems()
        
        for item in arrayOfFetchItems {
            
            if item.event == self.currentEvent {
                
                arrayOfItems.append(item)
            }
        }
        
        for item in arrayOfItems {
            var itemQuantity = 0
            var arrayOfSubItems = [SubItem]()
            
            for subItem in arrayOfFetchedSubItems {
                
                if subItem.item == item {
                    
                    arrayOfSubItems.append(subItem)
                }
            }
            
            for subItem in arrayOfSubItems {
                
                if let quan = subItem.quantity {
                    
                    itemQuantity = itemQuantity + Int(quan)
                }
            }
            
            if let price = item.price {
                
                inventoryTotal = inventoryTotal + (Double(itemQuantity) * Double(price))
            }
        }
        
        if let formattedString = numFormatter.stringFromNumber(inventoryTotal) {
            
            self.inventoryTotalLabel.text = "$\(formattedString)"
            
        }
    }
    
    //MARK: - Sales for the day calculations
    func calculateSalesForTheDay() {
        
        var totalSales: Double = 0
        var cashTotal: Double = 0
        var cardTotal: Double = 0
        var profitTotal: Double = 0
        
        if self.salesForSearchedDay.count != 0 {
            
            for sale in salesForSearchedDay {
                
                if let amount = sale.amount {
                    
                    totalSales = totalSales + Double(amount)
                    
                }
                
                if sale.type == "Cash" {
                    
                    if let amount = sale.amount {
                        
                        cashTotal = cashTotal + Double(amount)
                    }
                }
                
                if sale.type == "Card" {
                    
                    if let amount = sale.amount {
                        
                        cardTotal = cardTotal + Double(amount)
                    }
                }
                
                if let amount = sale.amount {
                    
                    if let cost = sale.initialCost {
                        
                        let profit = Double(amount) - Double(cost)
                        
                        profitTotal = profitTotal + profit
                    }
                }
            }
        }
        
        if let formattedString = numFormatter.stringFromNumber(totalSales) {
            
            self.totalSalesLabel.text = "$\(formattedString)"
        }
        
        if let formattedString = numFormatter.stringFromNumber(cashTotal) {
            
            self.cashTotalLabel.text = "$\(formattedString)"
        }
        
        if let formattedString = numFormatter.stringFromNumber(cardTotal) {
            
            self.cardTotalLabel.text = "$\(formattedString)"
        }
        
        if let formattedString = numFormatter.stringFromNumber(profitTotal) {
            
            self.profitLabel.text = "$\(formattedString)"
        }
    }
    
    //MARK: - Present Alert
    func presentAlert(message: String) {
        
        let alert = UIAlertController(title: "\(message)",
                                      message: nil,
                                      preferredStyle: .Alert)
        
        let action = UIAlertAction(title: "Ok", style: .Default) { (action: UIAlertAction) -> Void in
            
        }
        
        alert.addAction(action)
        
        presentViewController(alert,
                              animated: true,
                              completion: nil)
    }
    
    //MARK: - Set up x axis fields
    func setUpXAxis(interval: Double) {
        
        self.timeStrings = []
        
        var times = [NSDate]()
        
        var startDate = self.getStartOfDay(startDatePicker.date)
        
        formatter.dateFormat = "h:mm a"
        formatter.AMSymbol = "AM"
        formatter.PMSymbol = "PM"
        
        for _ in 1...24 {
            
            times.append(startDate)
            
            let timeString = formatter.stringFromDate(startDate)
            
            self.timeStrings.append(timeString)
            
            startDate = startDate.dateByAddingTimeInterval(3600)
            
        }
        
        self.setUpYAxis(times)
        
    }
    
    //MARK: - Set up y axis fields
    func setUpYAxis(times: [NSDate]) {
        
        self.salesDoubles.removeAll()
        
        for time in times {
            
            var total: Double = 0
            
            for sale in arrayOfSales {
                
                if let created = sale.created {
                    
                    if self.isWithinIntervals(time, createdDate: created, timeInterval: 3600) {
                        
                        if let saleAmount = sale.amount {
                            
                            total = total + Double(saleAmount)
                            
                        }
                    }
                }
            }
            
            self.salesDoubles.append(total)
            
        }
        self.setChart(timeStrings, values: salesDoubles)
    }
    
    //MARK: - Set Chart
    func setChart(dataPoints: [String], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = LineChartDataSet(yVals: dataEntries, label: "Total Sales Per Hour")
        let chartData = LineChartData(xVals: timeStrings, dataSet: chartDataSet)
        lineChartView.data = chartData
        
        lineChartView.descriptionText = ""
        
        chartDataSet.colors = [UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)]
        lineChartView.scaleXEnabled = true
        lineChartView.scaleYEnabled = false
        
        lineChartView.xAxis.labelPosition = .Bottom
        
        lineChartView.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 0.2)
        
        lineChartView.animate(xAxisDuration: 1, yAxisDuration: 1)
        
    }
    
    //MARK: - Save/email tapped
    func saveEmailTapped() {
        
        self.screenShotMethod()
        self.presentEmailController()
    }
    
    //MARK: - Screen shot method
    func screenShotMethod() {
        
        //Create the UIImage
        UIGraphicsBeginImageContext(view.frame.size)
        
        if let graphicsContext = UIGraphicsGetCurrentContext() {
            
            view.layer.renderInContext(graphicsContext)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            
            self.imageData = UIImagePNGRepresentation(image)
            
            UIGraphicsEndImageContext()
            
            //Save it to the camera roll
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            
        }
    }
    
    //MARK: - Email Controller
    func presentEmailController() {
        
        let emailTitle = "Sales Report"
        let messageBody = "Here is your M3RCH sales report"
        let toRecipients = [""]
        
        let mailController = MFMailComposeViewController()
        
        mailController.mailComposeDelegate = self
        
        if MFMailComposeViewController.canSendMail() {
            
            mailController.setSubject(emailTitle)
            
            mailController.setMessageBody(messageBody, isHTML: false)
            
            mailController.setToRecipients(toRecipients)
            
            if let data = self.imageData {
                
                mailController.addAttachmentData(data, mimeType: "image/png", fileName: "image.png")
                
                self.presentViewController(mailController, animated: true, completion: nil)
            }
            
        } else {
            
            print("cannot send mail")
            
        }
    }
    
    //MARK: - Email Controller Delegate
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch (result)
        {
            
        case MFMailComposeResultCancelled:
            
            break
            
        case MFMailComposeResultSaved:
            
            break
            
        case MFMailComposeResultSent:
            
            break
            
        case MFMailComposeResultFailed:
            
            print("Mail sent failure: \(error)")
            break
            
        default:
            
            break
            
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    //MARK: - Helper methods
    func isWithinIntervals(startDate: NSDate, createdDate: NSDate, timeInterval: NSTimeInterval) -> Bool {
        
        let startInterval = startDate.timeIntervalSince1970
        let endInterval = startInterval + timeInterval
        let createdDateInterval = createdDate.timeIntervalSince1970
        
        if createdDateInterval >= startInterval && createdDateInterval <= endInterval {
            return true
            
        }
        
        return false
    }
    
    func getStartOfDay(date: NSDate) -> NSDate {
        
        formatter.dateFormat = "MM/dd/yyyy"
        let dateString = "\(formatter.stringFromDate(date)) 00:00 AM"
        formatter.dateFormat = "MM/dd/yyyy hh:mm a"
        formatter.AMSymbol = "AM"
        formatter.PMSymbol = "PM"
        
        if let newDate = formatter.dateFromString(dateString) {
            
            return newDate
        }
        
        return NSDate()
    }
    
    
}
