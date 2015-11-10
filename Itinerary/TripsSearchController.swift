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
    var dismissBlock: (() -> ())?
    
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
            
            // Prompt for Unsubscribe
            let alertController = UIAlertController(title: "Alert!", message: "Do you want to unsubsribe to this trip?", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { alertAction in }
            let unsubscribeAction = UIAlertAction(title: "Unsubscribe", style: .Destructive) { alertAction in
                
                dispatchMainQueue {
                    CDManager.sharedInstance.deleteTrip(cdtrip)
                    CKManager.sharedInstance.unsubscribeToTrip(cdtrip.recordID)
                    self.tableView.reloadData()
                }
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(unsubscribeAction)

            presentViewController(alertController, animated: true) {}
            
        } else {
            
            // Create and subscribe
            CKManager.sharedInstance.subscribeToTrip(trip.recordID) { success in
                var message = ""
                
                if success {
                    CDManager.sharedInstance.createTrip(trip.record, owned: false)
                    message = "Successfully subscribed to trip."
                } else {
                    message = "Unable to subscribe to trip."
                }
                
                let alertController = UIAlertController(title: "Alert!", message: message, preferredStyle: .Alert)
                let dismissAction = UIAlertAction(title: "Dismiss", style: .Cancel) { alertAction in }
                alertController.addAction(dismissAction)

                
                dispatchMainQueue {
                    self.presentViewController(alertController, animated: true) {}
                    self.tableView.reloadData()
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
