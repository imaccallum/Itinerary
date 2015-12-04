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
        print("NOTIFICATION")
        print(application.applicationState.rawValue)
        guard application.applicationState == .Background || application.applicationState == .Active else {
            completionHandler(.NoData)
            return
        }

        let notification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String: NSObject])
        
        print(notification.alertBody)
        
        notification.alertBody
        handleNotification(notification)
        completionHandler(.NewData)
    }
    
    func handleNotification(notification: CKNotification) {
        
        if notification.notificationType == .Query {
            let queryNotification = notification as! CKQueryNotification
            guard let id = queryNotification.recordID else { return }
            print("query notification")
            
            
            
            // Fetch Record to determine type
            CKManager.sharedInstance.publicDatabase.fetchRecordWithID(id) { record, error in
                print(error?.localizedDescription)
                guard let record = record else {
                    CDManager.sharedInstance.deleteEvent(id)
                    CDManager.sharedInstance.deleteTrip(id)
                    
                    return
                
                }
                print(record.recordType)
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