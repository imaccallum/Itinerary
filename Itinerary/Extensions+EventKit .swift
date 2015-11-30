//
//  Extensions+EventKit .swift
//  Itinerary
//
//  Created by Ian MacCallum on 11/30/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//

import Foundation
import EventKit

extension EKEvent {
    convenience init(event: Event, inEventStore eventStore: EKEventStore, forCalendar cal: EKCalendar?) {
        self.init(eventStore: eventStore)
        
        title = event.title ?? ""
        recurrenceRules = nil
        
        guard let start = event.start else { return }
        startDate = start
        
        guard let end = event.end else { return }
        endDate = end
        
        guard let cal = cal else { return }
        calendar = cal
    }
}