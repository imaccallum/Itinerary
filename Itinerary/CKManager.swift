//
//  CloudManager.swift
//  SubscribedList
//
//  Created by Ian MacCallum on 7/30/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//

import Foundation
import CloudKit
import CoreData
import UIKit


class CKManager {
    static let sharedInstance = CKManager()
    var container: CKContainer { return CKContainer.defaultContainer() }
    var publicDatabase: CKDatabase { return container.publicCloudDatabase }
    


      func fetchRecord(id: CKRecordID, completion: CKRecord? -> Void) {
        publicDatabase.fetchRecordWithID(id, completionHandler: { record, error in
            completion(record)
        })
    }
}

// MARK: - Event Subscriptions
extension CKManager {
    
}