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
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
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
        print("select row")
        guard let event = fetchedResultsController.objectAtIndexPath(indexPath) as? Event else { return }
        performSegueWithIdentifier("EditTripSegue", sender: event)
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

