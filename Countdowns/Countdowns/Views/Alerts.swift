//
//  Alerts.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-23.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit

class Alerts {
    static func didConfirmDeletion(of event: Event, with viewController: UIViewController) -> Bool {
        var didConfirmDeletion: Bool
        
        let alert = UIAlertController(
            title: "Delete?",
            message: "Are you sure you want to delete event \"\(event.name)\"?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: { (action) in
                didConfirmDeletion.isFalseByRef()
        }))
        alert.addAction(UIAlertAction(
            title: "Delete",
            style: .destructive,
            handler: { (action) in
                didConfirmDeletion.isTrueByRef()
        }))
        
        viewController.present(alert, animated: true, completion: nil)
        
        return didConfirmDeletion
    }
}

extension Bool {
    mutating func isTrueByRef() {
        self = true
    }
    
    mutating func isFalseByRef() {
        self = false
    }
}
