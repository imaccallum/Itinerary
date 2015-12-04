//
//  TripsSearchController.swift
//  Itinerary
//
//  Created by Ian MacCallum on 10/13/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class TripsSearchController: UITableViewController {
    var filteredResults: [CKTrip] = []
    var dismissBlock: Block?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "TripSearchCell", bundle: nil), forCellReuseIdentifier: "TripSearchCellID")
        tableView.delegate = self
    }
}

extension TripsSearchController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredResults.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TripSearchCellID", forIndexPath: indexPath) as! TripSearchCell
        
        let trip = filteredResults[indexPath.row]
        
        cell.textLabel?.text = trip.title ?? nil
        cell.accessoryType = CDManager.sharedInstance.fetchTrip(trip.recordID) == nil ? .None : .Checkmark
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let trip = filteredResults[indexPath.row]
        
        // Check if trip exists
        if let cdtrip = CDManager.sharedInstance.fetchTrip(trip.recordID) {
            
            // Check if owned
            var messageString = ""
            var unsubscribeString = "Unsubscribe"
            
            if cdtrip.owned?.boolValue == true {
                messageString = "You created this trip. Do you want to delete it?"
                unsubscribeString = "Delete"
            } else {
                messageString = "Do you want to unsubsribe to this trip?"
            }
            
            // Prompt for Unsubscribe
            let alertController = UIAlertController(title: "Alert!", message: messageString, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { alertAction in }
            let unsubscribeAction = UIAlertAction(title: unsubscribeString, style: .Destructive) { alertAction in
                
                dispatchMainQueue {
                    CDManager.sharedInstance.deleteTrip(cdtrip)
                    
                    guard let id = cdtrip.recordID else { return }
                    
                    if cdtrip.owned == true {
                        // Delete ckrecord
                        CKManager.sharedInstance.deleteTrip(id)
                    } else {
                        // Unsubscribe
                        CKManager.sharedInstance.unsubscribeToTrip(id)
                    }
                    self.tableView.reloadData()
                }
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(unsubscribeAction)

            presentViewController(alertController, animated: true) {}
            
        } else {
            // Check if trip is password protected
            
            if let recordPassword = trip.password {
                // Password protected
                let alertController = UIAlertController(title: "Alert!", message: "This trip is password protected. Please enter password:", preferredStyle: .Alert)
                alertController.addTextFieldWithConfigurationHandler { textField in
                    textField.placeholder = "Password"
                    textField.secureTextEntry = true
                }
                
                let subscribeAction = UIAlertAction(title: "Subscribe", style: .Default) { action in
                    
                    if alertController.textFields?.first?.text == recordPassword {
                        
                        // Create and subscribe
                        CKManager.sharedInstance.subscribeToTrip(trip.recordID) { success in
                            var message = ""
                            
                            if success {
                                CDManager.sharedInstance.createTrip(trip.record, owned: false)
                                message = "Successfully subscribed to trip"
                            } else {
                                message = "Unable to subscribe to trip"
                            }
                            
                            dispatchMainQueue {
                                self.alertMessage(message)
                                self.tableView.reloadData()
                            }
                        }
                        
                    } else {
                        // Incorrect password
                        self.alertMessage("Incorrect password")
                    }
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in }
                
                alertController.addAction(subscribeAction)
                alertController.addAction(cancelAction)
                
                presentViewController(alertController, animated: true) {}

            } else {
                // Not password protected
                
                // Create and subscribe
                CKManager.sharedInstance.subscribeToTrip(trip.recordID) { success in
                    var message = ""
                    
                    if success {
                        CDManager.sharedInstance.createTrip(trip.record, owned: false)
                        message = "Successfully subscribed to trip"
                    } else {
                        message = "Unable to subscribe to trip"
                    }
                    
                    dispatchMainQueue {
                        self.alertMessage(message)
                        self.tableView.reloadData()
                    }
                }

            }
        }
    }

    func alertController(message: String) -> UIAlertController {
        let alertController = UIAlertController(title: "Alert!", message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Dismiss", style: .Cancel) { alertAction in }
        alertController.addAction(cancelAction)
        return alertController
    }
}
