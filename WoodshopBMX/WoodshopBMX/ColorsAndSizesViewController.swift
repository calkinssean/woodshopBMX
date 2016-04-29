//
//  ColorsAndSizesViewController.swift
//  M3rch
//
//  Created by Sean Calkins on 4/13/16.
//  Copyright © 2016 Sean Calkins. All rights reserved.
//

import UIKit

class ColorsAndSizesViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: - Properties
    var currentEvent: Event?
    var currentItem: Item?
    var subItems = [SubItem]()
    
    //MARK: - Outlets
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var customSizeTextField: UITextField!
    @IBOutlet var quantityTextFields: [UITextField]!
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchedSubItems = DataController.sharedInstance.fetchSubItems()
        for subItem in fetchedSubItems {
            
            if subItem.item == self.currentItem {
                
                self.subItems.append(subItem)
                
            }
            
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: #selector(self.saveSubItems))
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(self.keyboardWillShow(_:)),
            name: UIKeyboardWillShowNotification,
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(self.keyboardWillHide(_:)),
            name: UIKeyboardWillHideNotification,
            object: nil
        )
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let event = self.currentEvent {
            
            if event.name == "WoodShop" {
                
                self.backgroundImageView.image = UIImage(named: "wood copy")
            }
        }
        
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //MARK: - Scroll view keyboard methods
    func adjustInsetForKeyboardShow(show: Bool, notification: NSNotification) {
        guard let value = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue else { return }
        scrollView.contentInset.bottom = 0
        scrollView.scrollIndicatorInsets.bottom = 0
        let keyboardFrame = value.CGRectValue()
        let adjustmentHeight = (CGRectGetHeight(keyboardFrame) + 20) * (show ? 1 : -1)
        scrollView.contentInset.bottom += adjustmentHeight
        scrollView.scrollIndicatorInsets.bottom += adjustmentHeight
    }
    
    func keyboardWillShow(notification: NSNotification) {
        adjustInsetForKeyboardShow(true, notification: notification)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        adjustInsetForKeyboardShow(false, notification: notification)
    }
    
    //MARK: Save sub items
    func saveSubItems() {
        
        var saved = false
        
        for textField in quantityTextFields {
            
            //Ensure there is text in the field before saving
            if textField.text != "" {
                
                if let qty = Double(textField.text!) {
                    
                    if qty < 500000 && qty > 0 {
                        
                        if self.customSizeTextField.text != "" {
                            
                            if let size = self.customSizeTextField.text {
                                
                                let color = setColorForSubItem(textField)
                                
                                if let initialCost = self.currentItem?.purchasedPrice {
                                    
                                    if self.countAmountOfSizes() < 16 {
                                        
                                        //Data controller seed sub item
                                        if DataController.sharedInstance.seedSubItem(Double(initialCost), quantity: qty, color: color, size: size, item: self.currentItem!) {
                                            
                                            textField.text = ""
                                            
                                            saved = true
                                        }
                                    } else {
                                        presentAlert("Max amount of sizes is 15")
                                    }
                                }
                            }
                        } else {
                            
                            let color = setColorForSubItem(textField)
                            
                            if let initialCost = self.currentItem?.purchasedPrice {
                                
                                if DataController.sharedInstance.seedSubItem(Double(initialCost), quantity: qty, color: color, size: "None", item: self.currentItem!) {
                                    
                                    textField.text = ""
                                    
                                    saved = true
                                    
                                }
                            }
                        }
                    } else {
                        presentAlert("Only numbers between 0 and 500,000 please")
                    }
                } else {
                    presentAlert("Quantity can only be a number")
                }
            }
        }
        if saved {
            customSizeTextField.text = ""
            performSegueWithIdentifier("unwindFromColors", sender: self)
        }
    }
    
    //MARK: - Text field delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == customSizeTextField {
            self.customSizeTextField.resignFirstResponder()
            quantityTextFields[0].becomeFirstResponder()
        }
        if textField == quantityTextFields[0] {
            quantityTextFields[0].resignFirstResponder()
            quantityTextFields[1].becomeFirstResponder()
        }
        if textField == quantityTextFields[1] {
            quantityTextFields[1].resignFirstResponder()
            quantityTextFields[2].becomeFirstResponder()
        }
        if textField == quantityTextFields[2] {
            quantityTextFields[2].resignFirstResponder()
            quantityTextFields[3].becomeFirstResponder()
        }
        if textField == quantityTextFields[3] {
            quantityTextFields[3].resignFirstResponder()
            quantityTextFields[4].becomeFirstResponder()
        }
        if textField == quantityTextFields[4] {
            quantityTextFields[4].resignFirstResponder()
            quantityTextFields[5].becomeFirstResponder()
        }
        if textField == quantityTextFields[5] {
            quantityTextFields[5].resignFirstResponder()
            quantityTextFields[6].becomeFirstResponder()
        }
        if textField == quantityTextFields[6] {
            quantityTextFields[6].resignFirstResponder()
            quantityTextFields[7].becomeFirstResponder()
        }
        if textField == quantityTextFields[7] {
            quantityTextFields[7].resignFirstResponder()
            quantityTextFields[8].becomeFirstResponder()
        }
        if textField == quantityTextFields[8] {
            quantityTextFields[8].resignFirstResponder()
            quantityTextFields[9].becomeFirstResponder()
        }
        if textField == quantityTextFields[9] {
            quantityTextFields[9].resignFirstResponder()
            quantityTextFields[10].becomeFirstResponder()
        }
        if textField == quantityTextFields[10] {
            quantityTextFields[10].resignFirstResponder()
        }
        
        return true
    }
    
    //MARK: - Set color for sub item
    func setColorForSubItem(textField: UITextField) -> String {
        
        //Saves the sub item color as a string for comparison purposes later
        if textField.tag == 1 {
            return "UIDeviceRGBColorSpace 0 0 0 1"
        }
        if textField.tag == 2 {
            return "UIDeviceRGBColorSpace 0 0 1 1"
        }
        if textField.tag == 3 {
            return "UIDeviceRGBColorSpace 0.6 0.4 0.2 1"
        }
        if textField.tag == 4 {
            return "UIDeviceRGBColorSpace 0 1 1 1"
        }
        if textField.tag == 5 {
            return "UIDeviceRGBColorSpace 0 1 0 1"
        }
        if textField.tag == 6 {
            return "UIDeviceRGBColorSpace 1 0 1 1"
        }
        if textField.tag == 7 {
            return "UIDeviceRGBColorSpace 1 0.5 0 1"
        }
        if textField.tag == 8 {
            return "UIDeviceRGBColorSpace 0.5 0 0.5 1"
        }
        if textField.tag == 9 {
            return "UIDeviceRGBColorSpace 1 0 0 1"
        }
        if textField.tag == 10 {
            return "UIDeviceRGBColorSpace 1 1 0 1"
        }
        if textField.tag == 11 {
            return "UIDeviceRGBColorSpace 1 1 1 1"
        } else {
            return "none"
        }
    }
    
    //MARK: - Check for max buttons
    func countAmountOfSizes() -> Int {
        
        var sizesArray = [String]()
        
        for item in subItems {
            
            if let size = item.size {
                if !sizesArray.contains(size) {
                    
                    sizesArray.append(size)
                }
            }
            
        }
        
        print(sizesArray.count)
        return sizesArray.count
        
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
    
}
