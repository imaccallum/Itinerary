//
//  CKManager+Events.swift
//  Itinerary
//
//  Created by Ian MacCallum on 10/13/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//

import Foundation
import CloudKit

extension CKManager {
    
    // Create
    func createEvents(events: [Event]?, forTripID id: CKRecordID?) {
        guard let id = id, events = events else { return }
        
        for event in events {
            var ckevent = CKEvent(event: event)
            ckevent.trip = CKReference(recordID: id, action: .DeleteSelf)
            
            publicDatabase.saveRecord(ckevent.record) { record, error in
                print(error?.localizedDescription)
                event.recordID = record?.recordID
                CDManager.sharedInstance.saveContext()
            }
        }
    }


    // Read
    func fetchEvents(forTripID tripID: CKRecordID, cursor: CKQueryCursor? = nil, fetchedRecords: [CKRecord] = [], completion: RecordsBlock?) {
        
        var records = fetchedRecords
        var operation: CKQueryOperation!
        
        if let cursor = cursor {
            operation = CKQueryOperation(cursor: cursor)
        } else {
            let predicate = NSPredicate(format: "trip = %@", tripID)
            let query = CKQuery(recordType: "Event", predicate: predicate)
            
            operation = CKQueryOperation(query: query)
        }
        
        operation.recordFetchedBlock = { record in
            records.append(record)
            print("new event record")
        }
        
        operation.queryCompletionBlock = { cursor, error in
            if let cursor = cursor {
                self.fetchEvents(forTripID: tripID, cursor: cursor, fetchedRecords: records, completion: completion)
            } else {
                completion?(records)
            }
        }
        
        CKManager.sharedInstance.publicDatabase.addOperation(operation)
    }
    
    func fetchEvent(id: CKRecordID, completion: RecordBlock?) {
        publicDatabase.fetchRecordWithID(id) { record, error in
            completion?(record)
        }
    }
    
    
    // Update
    func updateEvents(events: [Event], forTripID tripID: CKRecordID) {

        for event in events {
            
            // Creat event if it doesn't exist
            guard let id = event.recordID else {
                print("creating event")
                createEvents([event], forTripID: tripID)
                continue
            }
            
            
            // Fetch evevent to update it
            fetchEvent(id) { record in
                guard let record = record else { return }
                
                var ckevent = CKEvent(record: record)
                
                if ckevent.title != event.title || ckevent.start != event.start || ckevent.end != event.end {
                    
                    // Set properties on record
                    ckevent.title = event.title
                    ckevent.start = event.start
                    ckevent.end = event.end

                    print("events are not equal")
                    // Update record
                    self.publicDatabase.saveRecord(ckevent.record) { savedRecord, error in
                        print(error?.localizedDescription)
                    }
                } else {
                    print("\(event.title) is equal")
                }
            }
        }
    }
    
    
    // Delete
    func deleteEvent(id: CKRecordID?) {
        guard let id = id else { return }
        publicDatabase.deleteRecordWithID(id) { id, error in
            print(error?.localizedDescription)
        }
    }
}