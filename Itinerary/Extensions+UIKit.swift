//
//  Extensions+UIKit.swift
//  Itinerary
//
//  Created by Ian MacCallum on 12/1/15.
//  Copyright © 2015 Ian MacCallum. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func alertMessage(message: String) {
        
        let alertController = UIAlertController(title: "Alert!", message: message, preferredStyle: .Alert)
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .Cancel) { action in
        }
        
        alertController.addAction(dismissAction)

        presentViewController(alertController, animated: true) {}
    }
}