//
//  Extensions+NSDate.swift
//  Itinerary
//
//  Created by Ian MacCallum on 11/8/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//

import Foundation

extension NSDate: Comparable {
    
}

func + (date: NSDate, timeInterval: NSTimeInterval) -> NSDate {
    return date.dateByAddingTimeInterval(timeInterval)
}

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    if lhs.compare(rhs) == .OrderedSame {
        return true
    }
    return false
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    if lhs.compare(rhs) == .OrderedAscending {
        return true
    }
    return false
}