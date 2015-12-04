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

    convenience init() {
        let entity = NSEntityDescription.entityForName("Trip", inManagedObjectContext: CDManager.sharedInstance.context)!
        self.init(entity: entity, insertIntoManagedObjectContext: CDManager.sharedInstance.context)
    }
}