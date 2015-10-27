//
//  FoundationExtensions.swift
//  Itinerary
//
//  Created by Ian MacCallum on 10/25/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//

import Foundation

extension NSUserDefaults {
    func setDataObject<T: AnyObject where T: NSCoding>(object: T?, forKey key: String) {
        guard let object = object else { return }
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(object)
        setObject(data, forKey: key)
    }
    
    func dataObjectForKey(key: String) -> AnyObject? {
        guard let data = objectForKey(key) as? NSData else { return nil }
        return NSKeyedUnarchiver.unarchiveObjectWithData(data)
    }
}