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
            print("trip saved \(record?.recordID)")
            print(error?.localizedDescription)
            trip.recordID = record?.recordID
            let events = trip.events?.allObjects as? [Event] ?? []
            self.createEvents(events, forTripID: record?.recordID)
        }
    }

    // Read
    
    
    
    
    
    // Update
    func updateTrip(trip: Trip) {
    
    }
    
    
    
    
    // Delete
    func deleteTrip(id: CKRecordID) {
        publicDatabase.deleteRecordWithID(id) { id, error in
            print(error?.localizedDescription)
            print("deleted object \(id)")
        }
    }
}