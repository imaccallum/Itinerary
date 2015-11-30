//
//  TripViewController.swift
//  Itinerary
//
//  Created by Ian MacCallum on 10/13/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class TripViewController: UIViewController {
    
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    var fetchedResultsController: NSFetchedResultsController!
    var trip: Trip!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup FRC
        let fetchRequest = NSFetchRequest(entityName: "Event")
        let predicate = NSPredicate(format: "trip = %@", trip)
        let sortDescriptor0 = NSSortDescriptor(key: "start", ascending: true)
        let sortDescriptor1 = NSSortDescriptor(key: "end", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor0, sortDescriptor1]
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CDManager.sharedInstance.context, sectionNameKeyPath: nil, cacheName: nil)
        
        _ = try? fetchedResultsController.performFetch()

        
        // Detect if owned
        if trip.owned == false {
            navigationItem.rightBarButtonItem = nil
        }
        

        // Set Labels
        titleLabel.text = trip.title ?? ""
        locationLabel.text = trip.location ?? ""
        
        // Delegation
        eventsTableView.dataSource = self
        eventsTableView.delegate = self
        fetchedResultsController.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextObjectsDidChangeNotification, object: nil, queue: nil) { notification in
            // Update content
            self.titleLabel.text = self.trip.title ?? ""
            self.locationLabel.text = self.trip.location ?? ""
        }
    }
    
    @IBAction func editButtonPressed(sender: UIBarButtonItem) {
        performSegueWithIdentifier("EditTripSegue", sender: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditTripSegue" {
            let dvc = (segue.destinationViewController as? UINavigationController)?.viewControllers.first as? EditTripViewController
            dvc?.fetchedResultsController = fetchedResultsController
            dvc?.trip = trip
        }
    }
}


// MARK: - UITableViewDelegate
extension TripViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        guard let event = fetchedResultsController.objectAtIndexPath(indexPath) as? Event else { return }
        
        let alertController = UIAlertController(title: "Alert!", message: "Add event to calendar?", preferredStyle: .Alert)
        
        let allAction = UIAlertAction(title: "Add all events", style: .Default) { action in
            let events = event.trip?.events?.allObjects as? [Event]
            CAManager.sharedInstance.addAllEvents(events)
        }
        
        let oneAction = UIAlertAction(title: "Add this event", style: .Default) { action in
            CAManager.sharedInstance.addEvent(event)
        }

        let modalAction = UIAlertAction(title: "Edit and add this event", style: .Default) { action in
            CAManager.sharedInstance.addEventModally(event, fromViewController: self)
        }

        let dismissAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in }
        
        alertController.addAction(allAction)
        alertController.addAction(oneAction)
        alertController.addAction(modalAction)
        alertController.addAction(dismissAction)
        
        presentViewController(alertController, animated: true) {}
    }
}


extension TripViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EventCellID", forIndexPath: indexPath)
        if let event = fetchedResultsController.objectAtIndexPath(indexPath) as? Event {
            cell.textLabel?.text = event.title
            cell.detailTextLabel?.text = event.detailDescription
        }
        
        return cell
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TripViewController: NSFetchedResultsControllerDelegate {
    
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

