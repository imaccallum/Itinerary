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
    func createEvent(record: CKRecord, forTrip trip: CKRecord) {
        let newEvent = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: context) as! Event
        newEvent.trip = fetchTrip(trip.recordID)
        updateEvent(newEvent, withRecord: record)
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
    
    // Delete
    func deleteEvent(id: CKRecordID?) {
        guard let id = id else { return }

        if let event = fetchEvent(id) {
            CDManager.sharedInstance.context.deleteObject(event)
            saveContext()
        }
    }
}