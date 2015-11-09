//
//  Event.swift
//  Itinerary
//
//  Created by Ian MacCallum on 9/27/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//

import Foundation
import CoreData

class Event: NSManagedObject {

    convenience init() {
        let entity = NSEntityDescription.entityForName("Event", inManagedObjectContext: CDManager.sharedInstance.context)!
        self.init(entity: entity, insertIntoManagedObjectContext: CDManager.sharedInstance.context)
    }
    
    
    var needsPublish: Bool {
        guard let lastPublished = lastPublished else { return true }
        guard let lastUpdated = lastUpdated else { return true }
        return lastUpdated > lastPublished
    }
}
