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
            print("token saved")
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
            
            switch queryNotification.queryNotificationReason {
            case .RecordCreated:
                print("created")
                // This should never happen
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
}