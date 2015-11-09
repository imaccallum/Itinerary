//
//  File.swift
//  Itinerary
//
//  Created by Ian MacCallum on 10/13/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//

import Foundation
import CloudKit

extension CKManager {
    func subscription(forRecordWithID recordID: CKRecordID) -> CKSubscription {
        let predicate = NSPredicate(format: "recordID = %@", recordID)
        let subscription = CKSubscription(recordType: "Trip",
            predicate: predicate,
            options: [.FiresOnRecordCreation, .FiresOnRecordDeletion, .FiresOnRecordUpdate])
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = "An event has been modified!"
        notificationInfo.alertLocalizationKey = "%@"
        notificationInfo.alertLocalizationArgs = ["title"]
        notificationInfo.shouldBadge = false
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        return subscription
    }
    
    func subscribeToTrip(id: CKRecordID?, completion: (Bool -> Void)?) {
        print("subscribe")
        guard let id = id else { return }
        
        let sub = subscription(forRecordWithID: id)
        
        CKManager.sharedInstance.publicDatabase.saveSubscription(sub) { subscription, error in
            print(subscription)
            print(error?.localizedDescription)
            guard let error = error else {
                completion?(true)
                return
            }
   
            completion?(false)
            
        }
    }
    
    func unsubscribeToTrip(id: CKRecordID?) {
        guard let id = id else { return }
        
        CKManager.sharedInstance.publicDatabase.deleteSubscriptionWithID(subscription(forRecordWithID: id).subscriptionID) { subID, error in
            guard let _ = subID else { return }
        }
    }
}