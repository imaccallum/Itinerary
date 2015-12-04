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
    
    var detailDescription: String {
        var text = ""
        guard let start = start else { return text }
        
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        formatter.dateStyle = .MediumStyle
        
        text += formatter.stringFromDate(start)
        
        guard let end = end else { return text }
        text += " - \(formatter.stringFromDate(end))"
        return text
    }
    
    var section: String? {
        
        let date = NSDate()
        
        if date < start {
            return "Upcoming"
        } else if date >= start && date <= end {
            return "In Progress"
        } else if date > end {
            return "Past"
        } else {
            return "Other"
        }
    }
}
