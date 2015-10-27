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


struct CKEvent {
    let record: CKRecord

    init(record: CKRecord) {
        self.record = record
    }
    
    init(event: Event) {
        self.init()
        title = event.title
        start = event.start
        end = event.end
    }
    
    init() {
        record = CKRecord(recordType: "Event")
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