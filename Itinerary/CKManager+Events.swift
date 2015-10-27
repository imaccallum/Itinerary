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
    func createEvents(events: [Event], forTripID id: CKRecordID?) {
        guard let id = id else { return }
        
        let records = events.map { event -> CKRecord in
            var temp = CKEvent(event: event)
            event.recordID = temp.recordID
            temp.trip = CKReference(recordID: id, action: .DeleteSelf)
            return temp.record
        }
        print("\(records.count) events to save")
        
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        
        operation.perRecordCompletionBlock = { record, error in
            guard let record = record else { return }
            print("saved record id: \(record.recordID)")
        }
        
        operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
            guard let savedRecords = savedRecords else { return }
            print("\(savedRecords.count) records saved")
        }
        
        CKManager.sharedInstance.publicDatabase.addOperation(operation)
    }
    

    // Read
    func fetchEvents(forTrip trip: CKRecord, cursor: CKQueryCursor? = nil, fetchedRecords: [CKRecord] = [], completion: ([CKRecord] -> Void)?) {
        
        var records = fetchedRecords
        var operation: CKQueryOperation!
        
        if let cursor = cursor {
            operation = CKQueryOperation(cursor: cursor)
        } else {
            let predicate = NSPredicate(format: "trip = %@", trip)
            let query = CKQuery(recordType: "Event", predicate: predicate)
            
            operation = CKQueryOperation(query: query)
        }
        
        operation.recordFetchedBlock = { record in
            records.append(record)
        }
        
        operation.queryCompletionBlock = { cursor, error in
            
            if let cursor = cursor {
                self.fetchEvents(forTrip: trip, cursor: cursor, fetchedRecords: records, completion: completion)
            } else {
                completion?(records)
            }
        }
        
        CKManager.sharedInstance.publicDatabase.addOperation(operation)
    }
    
    
    
    
    // Update
    
    
    
    
    
    // Delete
    func deleteEvent(id: CKRecordID?) {
        guard let id = id else { return }
        publicDatabase.deleteRecordWithID(id) { id, error in
            print(error?.localizedDescription)
            print("deleted object \(id)")
        }
    }
}