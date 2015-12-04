//
//  Extensions+Typealias.swift
//  Itinerary
//
//  Created by Ian MacCallum on 11/30/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//

import Foundation
import CloudKit

typealias Block = () -> ()
typealias SuccessBlock = Bool -> ()
typealias RecordsBlock = [CKRecord] -> ()
typealias RecordBlock = CKRecord? -> ()