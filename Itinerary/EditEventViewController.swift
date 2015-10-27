//
//  AddEventViewController.swift
//  Itinerary
//
//  Created by Ian MacCallum on 10/13/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class EditEventViewController: UIViewController {
    var event: Event?

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var startDateField: UIDateInputField!
    @IBOutlet weak var endDateField: UIDateInputField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Restore Values
        guard let event = event else { return }
        titleTextField.text = event.title
        startDateField.text = startDateField.stringFromDate(event.start)
        endDateField.text = endDateField.stringFromDate(event.end)
    }
    
    
    @IBAction func saveButtonPressed(sender: UIBarButtonItem) {

        // Save Values
        event?.title = titleTextField.text
        event?.start = startDateField.date
        event?.end = endDateField.date
        
        dismissViewControllerAnimated(true) {}
    }
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true) {}
    }
}