//
//  EditEventViewController.swift
//  Itinerary
//
//  Created by Edward Tischler on 10/13/15.
//  Copyright © 2015 Edward Tischler. All rights reserved.
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
        
        CDManager.sharedInstance.saveContext()
        
        // Restore Values
        guard let event = event else { return }
        print(event)
        titleTextField.text = event.title
        startDateField.date = event.start
        endDateField.date = event.end
    }
    
    
    @IBAction func saveButtonPressed(sender: UIBarButtonItem) {
        // Check fields exist
        guard let start = startDateField.date, end = endDateField.date, title = titleTextField.text else {
            alertMessage("Please enter a start date and an end date")
            return
        }
        
        // Check date order
        guard start.compare(end) == .OrderedAscending else {
            alertMessage("Start date must precede end date")
            return
        }
        
        
        // Save Values
        event?.title = title
        event?.start = start
        event?.end = end
        
        CDManager.sharedInstance.saveContext()
        dismissViewControllerAnimated(true) {}
    }
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        
        if startDateField.date == nil && endDateField.date == nil && (titleTextField.text == nil || titleTextField.text?.isEmpty == true) {
            // Delete event
            print("everything is nil")
            guard let event = event else { return }
            CDManager.sharedInstance.deleteEvent(event)
        }
        
        dismissViewControllerAnimated(true) {}
    }
}