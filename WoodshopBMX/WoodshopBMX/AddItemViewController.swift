//
//  AddItemViewController.swift
//  M3rch
//
//  Created by Sean Calkins on 4/4/16.
//  Copyright © 2016 Sean Calkins. All rights reserved.
//

import UIKit

class AddItemViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - Properties
    var currentEvent: Event?
    var currentItem: Item?
    var arrayOfSubItems = [SubItem]()
    let pickerController = UIImagePickerController()
    var imageName: String?
    var currentStock: Int = 0
    var newItem = true
    var sizeStrings = [String]()
    
    //MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var itemPriceTextField: UITextField!
    @IBOutlet weak var purchasedPriceTextField: UITextField!
    @IBOutlet weak var currentStockLabel: UILabel!
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
        self.setUpCurrentStockLabel()
        print(self.newItem)
        print("VIEW DID LOAD")
        self.imageView.frame.size = CGSizeMake(self.view.frame.width / 2, self.view.frame.width / 2)
        
    }

    //MARK: - Save tapped
    @IBAction func colorsAndSizesTapped(sender: UIButton) {
        
        if let itemName = itemNameTextField.text {
            if let price = Double(itemPriceTextField.text!) {
                if let purchasedPrice = Double(purchasedPriceTextField.text!) {
                    if let imageName = self.imageName {
                        if self.newItem == true {
                            if DataController.sharedInstance.seedItem(itemName, price: price, purchasedPrice: purchasedPrice, imageName: imageName, event: self.currentEvent!) {
                                let fetchedItems = DataController.sharedInstance.fetchItems()
                                for item in fetchedItems {
                                    if item.imageName == imageName {
                                        self.currentItem = item
                                    }
                                }
                                
                                self.newItem = false
                                self.performSegueWithIdentifier("showColorsSegue", sender: self)
                                
                            } else {
                                presentAlert("Please Enter All Fields Correctly")
                            }
                        } else {
                            self.performSegueWithIdentifier("showColorsSegue", sender: self)
                        }
                    } else {
                        presentAlert("Please Take a Picture")
                    }
                } else {
                    presentAlert("Please Enter a Purchased Price")
                }
            } else {
                presentAlert("Please Enter a Selling Price")
            }
        } else {
            presentAlert("Please Enter a Name")
        }
    }
    
    //MARK: - Take Picture Tapped
    @IBAction func takePictureTapped(sender: UIButton) {
        
        pickerController.delegate = self
        
        //checks if camera is available, if not look in photo library
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            
            pickerController.sourceType = .Camera
            pickerController.allowsEditing = true
            
        } else {
            
            pickerController.allowsEditing = true
            pickerController.sourceType = .PhotoLibrary
            
        }
        
        self.presentViewController(pickerController, animated: true) {
            
        }
    }
    
    //MARK: - Photo picker delegate
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        pickerController.dismissViewControllerAnimated(true) {
            
        }
    }
    
    //MARK: - Image picker controller
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            //creates a unique filename from timestamp
            let fileName: NSTimeInterval = NSDate().timeIntervalSince1970
            
            self.imageName = "\(fileName).png"
            
            if let imageName = self.imageName {
                
                //sets the image view to the chosen image
                self.imageView.image = editedImage
                
                //creates a new filepath from docs directory and fileName
                let filepath = getDocumentsDirectory().URLByAppendingPathComponent(imageName)
                
                print("THIS IS THE IMAGE NAME: \(imageName)")
                
                //converts image into data
                let pngData = UIImagePNGRepresentation(editedImage)
                
                do {
                    
                    //saves image to filepath in data form
                    try pngData?.writeToURL(filepath, options: [])
                    
                } catch {
                    
                    print("There was an error saving the image: \(error)")
                    
                }
            }
        }
        
        pickerController.dismissViewControllerAnimated(true) {
            
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        self.imageView.image = image
        pickerController.dismissViewControllerAnimated(true) {
            
        }
    }
    
    //MARK: - Prepare for segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showColorsSegue" {
            
            let controller = segue.destinationViewController as! ColorsAndSizesViewController
            
            controller.currentItem = self.currentItem
            
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
    
    //MARK: - Set Up Current Stock Label
    func setUpCurrentStockLabel() {
        
        let fetchedSubItems = DataController.sharedInstance.fetchSubItems()
        
        for subItem in fetchedSubItems {
            
            if subItem.item == self.currentItem {
                
                self.arrayOfSubItems.append(subItem)
                
            }
        }
        
        for item in arrayOfSubItems {
            
            self.currentStock = Int(self.currentStock + Int(item.quantity!))
            
        }
        
        self.currentStockLabel.text = "\(self.currentStock)"
        
    }
    
    //MARK: - Textfield Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == self.itemNameTextField {
            self.itemNameTextField.resignFirstResponder()
            self.itemPriceTextField.becomeFirstResponder()
        }
        
        if textField == self.itemPriceTextField {
            self.itemPriceTextField.resignFirstResponder()
            self.purchasedPriceTextField.becomeFirstResponder()
        }
        
        if textField == self.purchasedPriceTextField {
            self.purchasedPriceTextField.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
    
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
    
    //MARK: - Unwind Segue
    @IBAction func unwindSegue(segue: UIStoryboardSegue){
        self.newItem = false
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
