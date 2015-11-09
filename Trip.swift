//
//  Trip.swift
//  Itinerary
//
//  Created by Ian MacCallum on 9/27/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import CloudKit

class Trip: NSManagedObject {

    var needsPublish: Bool {
        
        print("updated: \(lastUpdated)")
        print("published: \(lastPublished)")
        
        guard let lastPublished = lastPublished else { return true }
        guard let lastUpdated = lastUpdated else { return true }
        return lastUpdated > lastPublished
    }
}


// MARK: - Create
extension Trip {
    
    convenience init(trip: CKTrip, owned: Bool) {
        let entity = NSEntityDescription.entityForName("Trip", inManagedObjectContext: CDManager.sharedInstance.context)!
        self.init(entity: entity, insertIntoManagedObjectContext: CDManager.sharedInstance.context)
        
        self.recordID = trip.recordID
        self.owned = owned
        self.title = trip.title
        
        CKManager.sharedInstance.fetchEvents(forTripID: trip.recordID) { records in
            records.forEach { CDManager.sharedInstance.createEvent($0, forTrip: trip.record) }
        }
    }
    
    convenience init(owned: Bool) {
        let entity = NSEntityDescription.entityForName("Trip", inManagedObjectContext: CDManager.sharedInstance.context)!
        self.init(entity: entity, insertIntoManagedObjectContext: CDManager.sharedInstance.context)
        self.owned = owned
        CDManager.sharedInstance.saveContext()
    }
}

// MARK: - Update
extension Trip {

}

