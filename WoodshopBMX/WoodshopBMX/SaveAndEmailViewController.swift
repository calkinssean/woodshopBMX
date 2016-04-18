//
//  SalesReportViewController.swift
//  M3rch
//
//  Created by Sean Calkins on 4/4/16.
//  Copyright © 2016 Sean Calkins. All rights reserved.
//

import UIKit
import Charts
import MessageUI

class SaveAndEmailViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    //MARK: - Properties
    var currentEvent: Event?
    var formatter = NSDateFormatter()
    
    var arrayOfSales = [Sale]()
    var arrayOfItems = [Item]()
    var timeStrings = [String]()
    var salesDoubles = [Double]()
    
    var imageData: NSData?
    var totalSales: Double = 0
    var cashSales: Double = 0
    var cardSales: Double = 0
    var compTotal: Double = 0
    var remainingInventory: Double = 0
    var venueCutTotal: Double = 0
    var salesTaxTotal: Double = 0
    var profit: Double = 0
    var timeInterval: Double = 3600
    
    //MARK: - Outlets
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var totalSalesLabel: UILabel!
    @IBOutlet weak var cashSalesLabel: UILabel!
    @IBOutlet weak var cardSalesLabel: UILabel!
    @IBOutlet weak var compTotalLabel: UILabel!
    @IBOutlet weak var remainingInventoryLabel: UILabel!
    @IBOutlet weak var venueCutLabel: UILabel!
    @IBOutlet weak var salesTaxLabel: UILabel!
    @IBOutlet weak var profitLabel: UILabel!
   
    @IBOutlet weak var saveEmailButton: UIButton!
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let fetchedItems = DataController.sharedInstance.fetchItems()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save/Email", style: .Plain, target: self, action: #selector(self.saveEmailTapped))
        
        formatter.dateFormat = "h:mm a"
        formatter.AMSymbol = "AM"
        formatter.PMSymbol = "PM"
        
        
        //Grabs all items for current event
        for item in fetchedItems {
            
            if item.event == self.currentEvent {
                
                self.arrayOfItems.append(item)
                
            }
            
        }
        
        let fetchedSales = DataController.sharedInstance.fetchSales()
        
        //Grabs all sales for current event
        for sale in fetchedSales {
            
            if sale.event == self.currentEvent {
                
                self.arrayOfSales.append(sale)
                
            }
            
        }
        
        self.makeCalculations()
        self.updateUI()
       // self.setUpXAxis(timeInterval)
        self.setChart(timeStrings, values: salesDoubles)
        
    }
    
    //MARK: - Save/email tapped
    func saveEmailTapped() {
        
        self.saveEmailButton.hidden = true
        
        self.screenShotMethod()
        self.presentEmailController()
        self.saveEmailButton.hidden = false
        
    }
    
    
    //MARK: - Set up x axis fields
//    func setUpXAxis(interval: Double) {
//        
//        self.timeStrings = []
//        
//        let eventStartInterval = ((self.currentEvent?.startDate)!).timeIntervalSince1970
//        if var startDate = (self.currentEvent?.startDate) {
//            let eventEndInterval = ((self.currentEvent?.endDate)!).timeIntervalSince1970
//            
//            if eventEndInterval > eventStartInterval {
//                
//                let i = Int((eventEndInterval - eventStartInterval) / interval)
//                
//                var times = [NSDate]()
//                
//                for _ in 0...(i) {
//                    
//                    times.append(startDate)
//                    
//                    let timeString = formatter.stringFromDate(startDate)
//                    
//                    self.timeStrings.append(timeString)
//                    
//                    startDate = startDate.dateByAddingTimeInterval(interval)
//                    
//                }
//                
//                self.setUpYAxis(times)
//                
//            }
//        }
//    }
    
    //MARK: - Set up y axis fields
    func setUpYAxis(times: [NSDate]) {
        
        self.salesDoubles.removeAll()
        
        for time in times {
            
            var total: Double = 0
            
            for sale in arrayOfSales {
                
                if let created = sale.created {
                    
                    if self.isWithinIntervals(time, createdDate: created) {
                        
                        if let saleAmount = sale.amount {
                            
                            total = total + Double(saleAmount)
                            
                        }
                    }
                }
            }
            
            self.salesDoubles.append(total)
            
        }
    }
    
    //MARK: - Set Chart
    func setChart(dataPoints: [String], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = LineChartDataSet(yVals: dataEntries, label: "Units Sold")
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
    
    //MARK: - Calculations
    func makeCalculations() {
        
        for sale in arrayOfSales {
            
            if sale.type == "Cash" {
                
                if let amount = sale.amount {
                    
                    //If sale type is "Cash" add them
                    self.cashSales = self.cashSales + Double(amount)
                }
            }
            
            if sale.type == "Card" {
                
                if let amount = sale.amount {
                    
                    //If sale type is "Card" add them
                    self.cardSales = cardSales + Double(amount)
                }
            }
            
            if sale.type != "Complementary" {
                
                if let amount = sale.amount {
                    
                    //If sale type is not "Complementary" add them
                    self.totalSales = self.totalSales + Double(amount)
                    
                }
            }
            
            if sale.type == "Complementary" {
                
                if let amount = sale.amount {
                    
                    //If sale type is "Complementary" add them
                    self.compTotal = compTotal + Double(amount)
                    
                }
            }
        }
        
        for item in arrayOfItems {
            
            if let price = item.price {
                
                let quantity = getCurrentStock(item)
                
                //For each remaining item, multiply quantity and price, then add it into the total
                self.remainingInventory = self.remainingInventory + (Double(price) * Double(quantity))
                
            }
        }
        
//        if let venueCut = self.currentEvent?.venueCut {
//            
//            //Venue cut percentage times the total sales
//            self.venueCutTotal = self.totalSales * Double(venueCut)
//            
//        }
//        
//        if let salesTax = self.currentEvent?.salesTax {
//            
//            //Sales tax percentage times the total sales
//            self.salesTaxTotal = self.totalSales * Double(salesTax)
//            
//        }
        
        //Total sales minus sales tax and venue cut
        self.profit = self.totalSales - self.venueCutTotal - self.salesTaxTotal
        
    }
    
    
    //Sets all the labels to the calculated totals
    func updateUI() {
        
        self.totalSalesLabel.text = "$\(self.totalSales)"
        self.cashSalesLabel.text = "$\(self.cashSales)"
        self.cardSalesLabel.text = "$\(self.cardSales)"
        self.compTotalLabel.text = "$\(self.compTotal)"
        self.remainingInventoryLabel.text = "$\(self.remainingInventory)"
        self.venueCutLabel.text = "$\(self.venueCutTotal)"
        self.salesTaxLabel.text = "$\(self.salesTaxTotal)"
        self.profitLabel.text = "$\(self.profit)"
        
    }
    
  
    //MARK: - Helper methods
    func isWithinIntervals(startDate: NSDate, createdDate: NSDate) -> Bool {
        
        let startInterval = startDate.timeIntervalSince1970
        let endInterval = startInterval + self.timeInterval
        let createdDateInterval = createdDate.timeIntervalSince1970
        
        if createdDateInterval >= startInterval && createdDateInterval <= endInterval {
            return true
        }
        return false
        
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
    
}
