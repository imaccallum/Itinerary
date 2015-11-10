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