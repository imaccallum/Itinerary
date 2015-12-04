//
//  CDManager+Trips.swift
//  Itinerary
//
//  Created by Ian MacCallum on 10/14/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

// MARK: - Trip CRUD
extension CDManager {
    // Create
    func createTrip(record: CKRecord?, owned: Bool) {
        let newTrip = NSEntityDescription.insertNewObjectForEntityForName("Trip", inManagedObjectContext: context) as! Trip
        newTrip.owned = owned
        
        if let record = record {
            updateTrip(newTrip, withRecord: record)
        }
        
        saveContext()
    }
    
    // Read
    func fetchTrip(id: CKRecordID) -> Trip? {
        
        let fetchRequest = NSFetchRequest(entityName: "Trip")
        fetchRequest.predicate = NSPredicate(format: "recordID = %@", id)
        fetchRequest.fetchLimit = 1
        
        return (try? context.executeFetchRequest(fetchRequest).first) as? Trip
    }
        
    // Update
    func updateTrip(trip: Trip, withRecord record: CKRecord) {
        print("updating trip")
        let cktrip = CKTrip(record: record)
        
        trip.title = cktrip.title
        trip.location = cktrip.location
        trip.password = cktrip.password
        trip.recordID = cktrip.recordID
        
        
        guard let id = trip.recordID else { return }
        
        CKManager.sharedInstance.fetchEvents(forTripID: cktrip.recordID) { records in
            
            // Remove outdated events
            let ids = records.map { $0.recordID }
            CDManager.sharedInstance.deleteAllEvents(forTrip: trip, exceptForIDs: ids)
            
            // Create or update other trips
            records.forEach { CDManager.sharedInstance.createOrUpdateEvent($0, forTripID: id) }
        }
        
        saveContext()
    }
    
    func handleTrip(id: CKRecordID) {
        CKManager.sharedInstance.fetchTrip(id) { record in
            guard let record = record else { return }
            
            if let trip = self.fetchTrip(id) {
                self.updateTrip(trip, withRecord: record)
            } else {
                self.createTrip(record, owned: false)
            }
        }
    }
    
    // Delete
    func deleteTrip(id: CKRecordID) {
        CKManager.sharedInstance.unsubscribeToTrip(id)
        
        if let trip = fetchTrip(id) {
            deleteTrip(trip)
        }
    }
    
    func deleteTrip(trip: Trip) {
        // Delete all events
        (trip.events?.allObjects as? [Event])?.forEach { CDManager.sharedInstance.deleteEvent($0) }
        // Delete trip
        CDManager.sharedInstance.context.deleteObject(trip)
        saveContext()
    }
    
    func deleteAllTrips(exceptForIDs ids: [CKRecordID]) {
        let fetchRequest = NSFetchRequest(entityName: "Trip")
        
        fetchRequest.predicate = NSPredicate(format: "NOT recordID IN %@", ids)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        _ = try? frc.performFetch()
        
        let outdatedEvents = frc.fetchedObjects as? [Trip]
        outdatedEvents?.forEach { deleteTrip($0) }
    }

    
    // Create or Update
    func createOrUpdateTrip(record: CKRecord) {
        if let trip = fetchTrip(record.recordID) {
            // Update Existing Trip
            updateTrip(trip, withRecord: record)
        } else {
            // Create New Record
            createTrip(record, owned: false)
        }
    }
}