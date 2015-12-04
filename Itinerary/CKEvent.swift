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


struct  CKEvent {
    var record: CKRecord

    init(record: CKRecord) {
        self.record = record
    }
    
    init(event: Event) {
        if let id = event.recordID {
            self.init(recordID: id)
        } else {
            self.init()
        }
        
        title = event.title
        start = event.start
        end = event.end
        
        guard let id = event.trip?.recordID else { return }
        trip = CKReference(recordID: id, action: .DeleteSelf)
    }
    
    init() {
        record = CKRecord(recordType: "Event")
    }
    
    init(recordID: CKRecordID) {
        record = CKRecord(recordType: "Event", recordID: recordID)
    }
    
    // Record Info
    var recordID: CKRecordID {
        return record.recordID
    }
    
    // Trip Info
    var trip: CKReference? {
        get { return record.objectForKey("trip") as? CKReference }
        set { record.setObject(newValue, forKey: "trip") }
    }
    
    // Basic Info
    var title: String? {
        get { return record.objectForKey("title") as? String }
        set { record.setObject(newValue, forKey: "title") }
    }
    
    // Date Info
    var start: NSDate? {
        get { return record.objectForKey("start") as? NSDate }
        set { record.setObject(newValue, forKey: "start") }
    }
    
    var end: NSDate? {
        get { return record.objectForKey("end") as? NSDate }
        set { record.setObject(newValue, forKey: "end") }
    }
}

extension CKEvent: Equatable {
    
}

func ==(lhs: CKEvent, rhs: CKEvent) -> Bool {
    if lhs.recordID == rhs.recordID &&
        lhs.title == rhs.title &&
        lhs.start == rhs.start &&
        lhs.end == rhs.end &&
        lhs.trip == rhs.trip {
            return true
    }
    return false
}
