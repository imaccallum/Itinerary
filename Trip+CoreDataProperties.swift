//
//  Trip+CoreDataProperties.swift
//  Itinerary
//
//  Created by Ian MacCallum on 9/28/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData
import CloudKit

extension Trip {
    @NSManaged var title: String?
    @NSManaged var owned: NSNumber?
    @NSManaged var recordID: CKRecordID?
    @NSManaged var location: String?
    @NSManaged var events: NSSet?
}
