//
//  CDManager+Events.swift
//  Itinerary
//
//  Created by Ian MacCallum on 10/14/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

// MARK: - Event CRUD
extension CDManager {
    // Create
    func createEvent(record: CKRecord, forTripID tripID: CKRecordID) {
        let newEvent = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: context) as! Event
        newEvent.trip = fetchTrip(tripID)
        updateEvent(newEvent, withRecord: record)
        saveContext()
    }
    
    
    // Read
    func fetchEvent(id: CKRecordID) -> Event? {
        
        let fetchRequest = NSFetchRequest(entityName: "Event")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "start", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "recordID = %@", id)
        fetchRequest.fetchLimit = 1
        
        return (try? context.executeFetchRequest(fetchRequest).first) as? Event
    }

    
    // Update
    func updateEvent(event: Event, withRecord record: CKRecord) {
        let ckevent = CKEvent(record: record)
        
        event.title = ckevent.title
        event.start = ckevent.start
        event.end = ckevent.end
        event.recordID = ckevent.recordID
        
        saveContext()
    }
 
    
    // Create or Update
    func createOrUpdateEvent(record: CKRecord, forTripID tripID: CKRecordID) {
        if let event = fetchEvent(record.recordID) {
            updateEvent(event, withRecord: record)
        } else {
            createEvent(record, forTripID: tripID)
        }
    }
    
    
    // Delete
    func deleteEvent(id: CKRecordID) {
        if let event = fetchEvent(id) {
            deleteEvent(event)
        }
    }
    
    func deleteEvent(event: Event) {
        // Delete event
        CDManager.sharedInstance.context.deleteObject(event)
        saveContext()
    }
    
    func deleteAllEvents(forTrip trip: Trip, exceptForIDs ids: [CKRecordID]) {
        let fetchRequest = NSFetchRequest(entityName: "Event")
        let predicate0 = NSPredicate(format: "trip = %@", trip)
        let predicate1 = NSPredicate(format: "NOT recordID IN %@", ids)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate0, predicate1])
        
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        _ = try? frc.performFetch()
        
        let outdatedEvents = frc.fetchedObjects as? [Event]
        outdatedEvents?.forEach { deleteEvent($0) }
    }

}