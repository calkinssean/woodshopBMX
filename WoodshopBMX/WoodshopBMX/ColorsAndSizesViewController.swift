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
    
    @IBOutlet var quantityTextFields: [UITextField]!
    
    @IBOutlet weak var customSizeTextField: UITextField!
    @IBOutlet weak var blackQuantityTextField: UITextField!
    @IBOutlet weak var blueQuantityTextField: UITextField!
    @IBOutlet weak var brownQuantityTextField: UITextField!
    @IBOutlet weak var cyanQuantityTextField: UITextField!
    @IBOutlet weak var greenQuantityTextField: UITextField!
    @IBOutlet weak var magentaQuantityTextField: UITextField!
    @IBOutlet weak var orangeQuantityTextField: UITextField!
    @IBOutlet weak var purpleQuantityTextField: UITextField!
    @IBOutlet weak var redQuantityTextField: UITextField!
    @IBOutlet weak var yellowQuantityTextField: UITextField!
    @IBOutlet weak var whiteQuantityTextField: UITextField!
    
    
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
        scrollView.contentInset.bottom = 20
        scrollView.scrollIndicatorInsets.bottom = 20
        let keyboardFrame = value.CGRectValue()
        let adjustmentHeight = (CGRectGetHeight(keyboardFrame)) * (show ? 1 : -1)
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
            self.blackQuantityTextField.becomeFirstResponder()
        }
        if textField == self.blackQuantityTextField {
            
            self.blackQuantityTextField.resignFirstResponder()
            self.blueQuantityTextField.becomeFirstResponder()
        }
        if textField == self.blueQuantityTextField {
            
            self.blueQuantityTextField.resignFirstResponder()
            self.brownQuantityTextField.becomeFirstResponder()
        }
        if textField == self.brownQuantityTextField {
            
            self.brownQuantityTextField.resignFirstResponder()
            self.cyanQuantityTextField.becomeFirstResponder()
        }
        if textField == self.cyanQuantityTextField {
            
            self.cyanQuantityTextField.resignFirstResponder()
            self.greenQuantityTextField.becomeFirstResponder()
        }
        if textField == self.greenQuantityTextField {
            
            self.greenQuantityTextField.resignFirstResponder()
            self.magentaQuantityTextField.becomeFirstResponder()
        }
        if textField == self.magentaQuantityTextField {
            
            self.magentaQuantityTextField.resignFirstResponder()
            self.orangeQuantityTextField.becomeFirstResponder()
        }
        if textField == self.orangeQuantityTextField {
            
            self.orangeQuantityTextField.resignFirstResponder()
            self.purpleQuantityTextField.becomeFirstResponder()
        }
        if textField == self.purpleQuantityTextField {
            
            self.purpleQuantityTextField.resignFirstResponder()
            self.redQuantityTextField.becomeFirstResponder()
        }
        if textField == self.redQuantityTextField {
            
            self.redQuantityTextField.resignFirstResponder()
            self.yellowQuantityTextField.becomeFirstResponder()
        }
        if textField == self.yellowQuantityTextField {
            
            self.yellowQuantityTextField.resignFirstResponder()
            self.whiteQuantityTextField.becomeFirstResponder()
        }
        if textField == self.whiteQuantityTextField {
            
            self.whiteQuantityTextField.resignFirstResponder()
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
