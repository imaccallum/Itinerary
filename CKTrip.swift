//
//  CKTrip.swift
//  Itinerary
//
//  Created by Ian MacCallum on 9/28/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//

import Foundation
import CloudKit
import CoreData
import UIKit


struct CKTrip {
    let record: CKRecord
    
    init(record: CKRecord) {
        self.record = record
    }
    
    init(trip: Trip) {
        self.init()
        title = trip.title
        location = trip.location
        password = trip.password
    }
    
    init() {
        record = CKRecord(recordType: "Trip")
    }
        
    var recordID: CKRecordID {
        return record.recordID
    }
        
    var title: String? {
        get { return record.objectForKey("title") as? String }
        set { record.setObject(newValue, forKey: "title") }
    }
    
    var location: String? {
        get { return record.objectForKey("location") as? String }
        set { record.setObject(newValue, forKey: "location") }
    }
    
    var password: String? {
        get { return record.objectForKey("password") as? String }
        set { record.setObject(newValue, forKey: "password") }
    }
    
    var isPrivate: Bool {
        return !(password ?? "").isEmpty
    }
}

extension CKTrip: Equatable {
    
}

func ==(lhs: CKTrip, rhs: CKTrip) -> Bool {
    if lhs.record == rhs.record {
        return true
    }
    return false
}
