//
//  CAManager.swift
//  Itinerary
//
//  Created by Edward Tischler on 11/20/15.
//  Copyright © 2015 Edward Tischler. All rights reserved.
//

import Foundation
import UIKit
import EventKit
import EventKitUI

class CAManager: NSObject {
    static let sharedInstance = CAManager()
    var store = EKEventStore()


    func checkAuthorizationStatus(completion: Block) {
        let status = EKEventStore.authorizationStatusForEntityType(.Event)
        
        if status == .Authorized {
            completion()
        } else {
            store.requestAccessToEntityType(.Event) { granted, error in
                if granted {
                    self.checkAuthorizationStatus { completion() }
                }
            }
        }
    }
    
    
    func addEventModally(event: Event, fromViewController viewController: UIViewController) {
        checkAuthorizationStatus {
            
            let addEventController = EKEventEditViewController()
            addEventController.eventStore = self.store
            addEventController.editViewDelegate = self
            let newEvent = EKEvent(event: event, inEventStore: self.store, forCalendar: self.getCalendar(forEvent: event))
            addEventController.event = newEvent
            
            viewController.presentViewController(addEventController, animated: true, completion: nil)
        }
    }
    
    
    func addAllEvents(events: [Event]?) {
        events?.forEach { self.addEvent($0) }
    }
    
    
    func addEvent(event: Event) {
        guard !eventExists(event) else { return }

        checkAuthorizationStatus {
            let newEvent = EKEvent(event: event, inEventStore: self.store, forCalendar: self.getCalendar(forEvent: event))
            
            do {
                try self.store.saveEvent(newEvent, span: EKSpan.ThisEvent)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    
    func eventExists(event: Event) -> Bool {
        guard let start = event.start, end = event.end else { return false }
        var match = false

        
        let predicate = store.predicateForEventsWithStartDate(start, endDate: end, calendars: nil)
        
        store.enumerateEventsMatchingPredicate(predicate) { existingEvent, stop in
            
            if existingEvent.title.lowercaseString == event.title?.lowercaseString {
                match = true
                return
            }
        }
        
        print("match \(match)")
        return match
    }
    
    func getCalendar(forEvent event: Event? = nil) -> EKCalendar? {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let id = defaults.stringForKey("calendarID") {

            let calendar = store.calendarsForEntityType(.Event).filter { $0.calendarIdentifier == id }
            return calendar.first
        
        } else {
            
            let calendar = EKCalendar(forEntityType: EKEntityType.Event, eventStore: store)
            calendar.title = event?.trip?.title ?? "Itinerary"
            calendar.CGColor = UIColor.redColor().CGColor
            calendar.source = self.store.defaultCalendarForNewEvents.source
            
            var error: NSError?
            do {
                try store.saveCalendar(calendar, commit: true)
            } catch let error1 as NSError {
                error = error1
            }
            
            if error == nil {
                defaults.setObject(calendar.calendarIdentifier, forKey: "calendarID")
            }
            
            return calendar
        }
    }
}

extension CAManager: EKEventEditViewDelegate {
    func eventEditViewControllerDefaultCalendarForNewEvents(controller: EKEventEditViewController) -> EKCalendar {
        return getCalendar()!
    }
    
    func eventEditViewController(controller: EKEventEditViewController, didCompleteWithAction action: EKEventEditViewAction) {
        controller.dismissViewControllerAnimated(true) {}
    }
}