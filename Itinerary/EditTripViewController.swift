//
//  CreateEditTripViewController.swift
//  Itinerary
//
//  Created by Ian MacCallum on 9/28/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import CoreData

class EditTripViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var eventsTableView: UITableView!

    var fetchedResultsController: NSFetchedResultsController!
    var trip: Trip!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup FRC
        let fetchRequest = NSFetchRequest(entityName: "Event")
        let predicate = NSPredicate(format: "trip = %@", trip)
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CDManager.sharedInstance.context, sectionNameKeyPath: nil, cacheName: nil)
        
        _ = try? fetchedResultsController.performFetch()

        // Delegation
        fetchedResultsController.delegate = self
        eventsTableView.dataSource = self
        eventsTableView.delegate = self
        
        // Update label
        titleTextField.text = trip.title
        locationTextField.text = trip.location
    }
    
    
    @IBAction func addEventButtonPressed(sender: UIButton) {
        let event = Event()
        event.trip = trip
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditEventSegue" {
            print("segue")
            let destination = (segue.destinationViewController as? UINavigationController)?.viewControllers.first as? EditEventViewController
            destination?.event = sender as? Event
        }
    }
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true) {}
    }
    
    
    @IBAction func publishButtonPressed(sender: UIBarButtonItem) {
        // Set Values
        trip.title = titleTextField.text
        trip.location = locationTextField.text
        CDManager.sharedInstance.saveContext()
        // Push to Cloud
        if let id = trip.recordID {
            // Update CKTrip
            print("updating trip id: \(id)")
            CKManager.sharedInstance.updateTrip(trip)
        } else {
            // Create CKTrip
            CKManager.sharedInstance.createTrip(trip)
        }
        
        dismissViewControllerAnimated(true) {}

    
    }
}

// MARK: - UITableViewDelegate
extension EditTripViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let event = fetchedResultsController.objectAtIndexPath(indexPath) as? Event else { return }
        performSegueWithIdentifier("EditEventSegue", sender: event)
    }
    
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let event = fetchedResultsController.objectAtIndexPath(indexPath) as? Event else { return }

        if editingStyle == .Delete {
            
            // Remove from local and cloud store
            let id = event.recordID
            CDManager.sharedInstance.deleteEvent(id)
            CKManager.sharedInstance.deleteEvent(id)
        }
    }
}


extension EditTripViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EditEventCellID", forIndexPath: indexPath)
        if let event = fetchedResultsController.objectAtIndexPath(indexPath) as? Event {
            cell.textLabel?.text = event.title
        }
        
        return cell
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension EditTripViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        eventsTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        eventsTableView.endUpdates()
    }
    
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

        switch type {
        case .Insert:
            eventsTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            eventsTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Move:
            eventsTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            eventsTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Update:
            eventsTableView.cellForRowAtIndexPath(indexPath!)
        }
    }
}