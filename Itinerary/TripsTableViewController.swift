//
//  TripsViewController.swift
//  Itinerary
//
//  Created by Ian MacCallum on 9/27/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class TripsTableViewController: UITableViewController {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    let context = CDManager.sharedInstance.context
    var fetchedResultsController: NSFetchedResultsController!
    var searchController: UISearchController!
    var searchResultsController: TripsSearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchResultsController = TripsSearchController()
        searchResultsController.dismissBlock = {
            self.searchController.active = false
        }
        
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        
        searchController.dimsBackgroundDuringPresentation = false // default is YES
        searchController.searchBar.delegate = self // so we can monitor text changes + others
        definesPresentationContext = true
        
        // Set FRC
        segmentChanged(segmentControl)
        
    }
    
    @IBAction func addButtonPressed(sender: UIBarButtonItem) {
        CDManager.sharedInstance.createTrip(nil, owned: true)
        segmentControl.selectedSegmentIndex = 1
        segmentChanged(segmentControl)
    }
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        setFetchedResultController(sender.selectedSegmentIndex == 0)
        tableView.tableHeaderView = sender.selectedSegmentIndex == 0 ? searchController.searchBar : nil
    }
    
    func setFetchedResultController(subscribed: Bool) {
        let fetchRequest = NSFetchRequest(entityName: "Trip")
        fetchRequest.predicate = NSPredicate(format: "owned = %@", !subscribed)
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        _ = try? fetchedResultsController.performFetch()
        fetchedResultsController.delegate = self

        tableView.reloadData()
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TripSegue" {
            guard let destination = segue.destinationViewController as? TripViewController, trip = sender as? Trip else { return }
            destination.trip = trip
        }
    }
}


// MARK: - UISearchBarDelegate
extension TripsTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchController.active = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarResultsListButtonClicked(searchBar: UISearchBar) {
        print("click")
    }
}


// MARK: - UISearchResultsUpdating
extension TripsTableViewController: UISearchResultsUpdating {
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let resultsController = searchController.searchResultsController as! TripsSearchController

        let searchString = searchController.searchBar.text ?? ""
        print(searchString)

        guard !searchString.isEmpty else {
            print("empty")
            resultsController.filteredResults = []
            return
        }

        // TODO: - Add RefreshControl Feedback
        let predicate = NSPredicate(format: "self contains %@", searchString)
        let query = CKQuery(recordType: "Trip", predicate: predicate)
        let database = CKContainer.defaultContainer().publicCloudDatabase
    
        database.performQuery(query, inZoneWithID: nil) { records, error in
            // Hand over the filtered results to our search results table.
            guard let records = records else { return }
            
            resultsController.filteredResults = records.map { CKTrip(record: $0) }

            dispatchMainQueue {
                resultsController.tableView.reloadData()
            }
        }
    }
}



// MARK: - UITableViewDataSource
extension TripsTableViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TripCellID", forIndexPath: indexPath)
        
        if let trip = fetchedResultsController.objectAtIndexPath(indexPath) as? Trip {
            cell.textLabel?.text = trip.title ?? "New Trip"
        }
        
        return cell
    }
    
    
}


// MARK: - UITableViewDelegate
extension TripsTableViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let trip = fetchedResultsController.objectAtIndexPath(indexPath) as? Trip else { return }
        performSegueWithIdentifier("TripSegue", sender: trip)
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            guard let trip = fetchedResultsController.objectAtIndexPath(indexPath) as? Trip else { return }
            // Remove from local store
            CDManager.sharedInstance.deleteTrip(trip)
            
            guard let id = trip.recordID else { return }
            
            if trip.owned == true {
                // Delete ckrecord
                CKManager.sharedInstance.deleteTrip(id)
            } else {
                // Unsubscribe
                CKManager.sharedInstance.unsubscribeToTrip(id)
            }
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TripsTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

        print("change object")
        
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
    }
}