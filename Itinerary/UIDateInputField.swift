//
//  UIDateInputField.swift
//  UIDateInputField
//
//  Created by Ian MacCallum on 10/13/15.
//  Copyright © 2015 Dance Marathon. All rights reserved.
//

import Foundation
import UIKit

class UIDateInputField: UITextField {
    private var previousDate: NSDate?
    private var previousText: String?
    var date: NSDate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .DateAndTime
        datePicker.addTarget(self, action: "datePickerValueChanged:", forControlEvents: .ValueChanged)
        inputView = datePicker
        
        let toolbar = UIToolbar()
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelButtonPressed:")
        let doneButton = UIBarButtonItem(title: "Done", style: .Done, target: self, action: "doneButtonPressed:")
        let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancelButton, space, doneButton], animated: true)
        toolbar.barStyle = .Default
        toolbar.sizeToFit()
        inputAccessoryView = toolbar
    }
    
    func cancelButtonPressed(sender: UIBarButtonItem) {
        print("cancel")
        resignFirstResponder()
        
        // Resets date property
        date = previousDate
        text = previousText
    }
    
    func doneButtonPressed(sender: UIBarButtonItem) {
        resignFirstResponder()
    }
    
    func datePickerValueChanged(sender: UIDatePicker) {
        text = stringFromDate(sender.date)
        date = sender.date
    }
    
    func stringFromDate(date: NSDate?) -> String? {
        guard let date = date else { return nil }
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        formatter.timeStyle = .ShortStyle
        return formatter.stringFromDate(date)
    }
}

extension UIDateInputField: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        previousDate = date
        previousText = text
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}