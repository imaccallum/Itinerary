//
//  AppDelegate+Subscriptions.swift
//  List
//
//  Created by Ian MacCallum on 10/7/15.
//  Copyright © 2015 Dance Marathon. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

extension AppDelegate {
    
    func registerForNotifications(application: UIApplication) {
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        guard application.applicationState == .Background || application.applicationState == .Active else {
            completionHandler(.NoData)
            return
        }

        let token = NSUserDefaults.standardUserDefaults().dataObjectForKey("notificationChangeToken") as? CKServerChangeToken
        print(token)
        
        let operation = CKFetchNotificationChangesOperation(previousServerChangeToken: token)
        
        operation.fetchNotificationChangesCompletionBlock = { newToken, error in
            guard let newToken = newToken else { return }
            NSUserDefaults.standardUserDefaults().setDataObject(newToken, forKey: "notificationChangeToken")
            completionHandler(.NewData)
        }
        
        operation.notificationChangedBlock = { notification in
            self.handleNotification(notification)
        }
        
        CKContainer.defaultContainer().addOperation(operation)
    }
    
    func handleNotification(notification: CKNotification) {
        
        if notification.notificationType == .Query {
            let queryNotification = notification as! CKQueryNotification
            guard let id = queryNotification.recordID else { return }

            // Fetch Record to determine type
            CKManager.sharedInstance.publicDatabase.fetchRecordWithID(id) { record, error in
                guard let record = record else { return }
                
                if record.recordType == "Trip" {
                    // Handle trip notification
                    self.handleTripNotification(queryNotification)
                } else if record.recordType == "Event" {
                    // Handle event notification
                    guard let tripID = CKEvent(record: record).trip?.recordID else { return }
                    self.handleEventNotification(queryNotification, forEventRecord: record, andTripID: tripID)
                }
            }
        }
    }
    
    func handleEventNotification(notification: CKQueryNotification, forEventRecord eventRecord: CKRecord, andTripID tripID: CKRecordID) {
        
        switch notification.queryNotificationReason {
        case .RecordCreated:
            print("created")
            CDManager.sharedInstance.createEvent(eventRecord, forTripID: tripID)
        case .RecordDeleted:
            print("deleted")
            CDManager.sharedInstance.deleteEvent(eventRecord.recordID)
        case .RecordUpdated:
            print("update")
            CDManager.sharedInstance.createOrUpdateEvent(eventRecord, forTripID: tripID)
        }
    }

    
    
    func handleTripNotification(notification: CKQueryNotification) {
        guard let id = notification.recordID else { return }
        
        switch notification.queryNotificationReason {
        case .RecordCreated:
            print("created")
            // This should never happen for trips
        case .RecordDeleted:
            print("deleted")
            CKManager.sharedInstance.unsubscribeToTrip(id)
            CDManager.sharedInstance.deleteTrip(id)
        case .RecordUpdated:
            print("update")
            CDManager.sharedInstance.handleTrip(id)
        }
    }
    
    
  }