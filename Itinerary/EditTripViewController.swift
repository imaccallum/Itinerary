//
//  CreateEditTripViewController.swift
//  Itinerary
//
//  Created by Edward Tischler on 9/28/15.
//  Copyright © 2015 Edward Tischler. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import CoreData

class EditTripViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var publishBarButton: UIBarButtonItem!

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
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CDManager.sharedInstance.context, sectionNameKeyPath: "section", cacheName: nil)
        
        _ = try? fetchedResultsController.performFetch()

        // Delegation
        fetchedResultsController.delegate = self
        eventsTableView.dataSource = self
        eventsTableView.delegate = self
        
        // Update label
        titleTextField.text = trip.title
        locationTextField.text = trip.location
        passwordTextField.text = trip.password
        
        // Add observers
        titleTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
        locationTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
        passwordTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
        
    }

    
    @IBAction func addEventButtonPressed(sender: UIButton) {
        let event = Event()
        event.trip = trip
        performSegueWithIdentifier("EditEventSegue", sender: event)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditEventSegue" {
            let destination = (segue.destinationViewController as? UINavigationController)?.viewControllers.first as? EditEventViewController
            destination?.event = sender as? Event
        }
    }
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        CDManager.sharedInstance.context.rollback()
        dismissViewControllerAnimated(true) {}
    }
    
    
    @IBAction func publishButtonPressed(sender: UIBarButtonItem) {
        
        CDManager.sharedInstance.saveContext()
        
        // Push to Cloud
        if let _ = trip.recordID {
            // Update CKTrip
            print("UPDATE EXISTING TRIP")
            CKManager.sharedInstance.updateTrip(trip)
        } else {
            // Create CKTrip
            print("CREATING NEW TRIP")
            CKManager.sharedInstance.createTrip(trip)
        }
        
        dismissViewControllerAnimated(true) {}
    }
    
    func textFieldDidChange(sender: UITextField) {
        if sender === titleTextField {
            trip.title = titleTextField.text
        } else if sender === locationTextField {
            trip.location = locationTextField.text
        } else if sender === passwordTextField {
            guard let text = passwordTextField.text else { return }
            trip.password = text.isEmpty ? nil : text
        }
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

            if let id = event.recordID {
                // Remove from local and cloud store
                CDManager.sharedInstance.deleteEvent(id)
                CKManager.sharedInstance.deleteEvent(id)
            } else {
                // Remove from local store only
                CDManager.sharedInstance.deleteEvent(event)
            }
        }
    }
}


extension EditTripViewController: UITableViewDataSource {
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EditEventCellID", forIndexPath: indexPath)
        if let event = fetchedResultsController.objectAtIndexPath(indexPath) as? Event {
            cell.textLabel?.text = event.title
            cell.detailTextLabel?.text = event.detailDescription
            
            let alpha: CGFloat = event.section == "Past" ? 0.25 : 1.0
            cell.textLabel?.alpha = alpha
            cell.detailTextLabel?.alpha = alpha
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController?.sections?[section].name
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
            eventsTableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
        case .Insert:
            eventsTableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            eventsTableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Move:
            eventsTableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            eventsTableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Update:
            eventsTableView.reloadSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        }
    }
}