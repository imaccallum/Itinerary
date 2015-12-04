//
//  CKManager+Trips.swift
//  Itinerary
//
//  Created by Ian MacCallum on 10/13/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//

import Foundation
import CloudKit

extension CKManager {

    // Create
    func createTrip(trip: Trip) {
        let cktrip = CKTrip(trip: trip)
        
        publicDatabase.saveRecord(cktrip.record) { record, error in
            trip.recordID = record?.recordID
            CDManager.sharedInstance.saveContext()

            let events = trip.events?.allObjects as? [Event] ?? []
            self.createEvents(events, forTripID: record?.recordID)
        }
    }

    
    // Read
    func fetchTrip(id: CKRecordID, completion: RecordBlock?) {
        publicDatabase.fetchRecordWithID(id) { record, error in
            completion?(record)
        }
    }
    

    // Update
    func updateTrip(trip: Trip) {
        guard let id = trip.recordID else { return }
        
        fetchTrip(id) { record in
            guard let record = record else { return }
            
            // Set properties on record
            var cktrip = CKTrip(record: record)

            if cktrip.title != trip.title || cktrip.location != trip.location || cktrip.password != trip.password {
                
                cktrip.title = trip.title
                cktrip.location = trip.location
                cktrip.password = trip.password
                
                // Update record
                self.publicDatabase.saveRecord(cktrip.record) { savedRecord, error in
                    print(error?.localizedDescription)
                }
            }
            
            CKManager.sharedInstance.updateEvents(trip.events?.allObjects as? [Event] ?? [], forTripID: id)

        }
    }
    
    
    // Delete
    func deleteTrip(id: CKRecordID) {
        publicDatabase.deleteRecordWithID(id) { id, error in
            print(error?.localizedDescription)
        }
    }
}