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
                event.recordID = record?.recordID
                event.lastPublished = NSDate()
            }
        }
    }


    // Read
    func fetchEvents(forTripID tripID: CKRecordID, cursor: CKQueryCursor? = nil, fetchedRecords: [CKRecord] = [], completion: ([CKRecord] -> Void)?) {
        
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
    
    func fetchEvent(id: CKRecordID, completion: (CKRecord? -> ())?) {
        publicDatabase.fetchRecordWithID(id) { record, error in
            completion?(record)
        }
    }
    
    
    // Update
    func updateEvents(events: [Event], forTripID tripID: CKRecordID) {

        for event in events {
            guard let id = event.recordID else {
                createEvents([event], forTripID: tripID)
                continue
            }
            
            fetchEvent(id) { record in
                guard let record = record else { return }
                
                // Set properties on record
                var ckevent = CKEvent(record: record)
                ckevent.title = event.title
                ckevent.start = event.start
                ckevent.end = event.end

                
                // Update record
                self.publicDatabase.saveRecord(ckevent.record) { savedRecord, error in
                    guard let savedRecord = savedRecord else { return }
                    
                    let savedEvent = CDManager.sharedInstance.fetchEvent(savedRecord.recordID)
                    savedEvent?.lastPublished = NSDate()
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