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
        let title = trip.title ?? "Unknown trip"
        var message = ""
        
        // Check if trip exists
        if let _ = CDManager.sharedInstance.fetchTrip(trip.recordID) {
            message = "Already subscribed to: \(title)"
        } else {
            // Create and subscribe
            CKManager.sharedInstance.subscribeToTrip(trip.recordID) { success in
                if success {
                    _ = Trip(trip: trip, owned: false)
                }
            }
            
            message = "Subscribed to: \(title)"
        }
        
        // Alert User
        let alertController = UIAlertController(title: "Alert!", message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Dismiss", style: .Cancel) { alertAction in }
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true) {
            self.dismissBlock?()
        }

    }
}
