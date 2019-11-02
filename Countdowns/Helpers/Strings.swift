//
//  Strings.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import Foundation

// String extensions to prevent "stringly typed" code.
extension String {
    
    static let countdownCellReuseID = "CountdownCell"
    
    // MARK: - Segue Identifiers
    
    static let addEventSegue = "AddEventSegue"
    static let eventDetailSegue = "EventDetailSegue"
    static let editEventSegue = "EditEventSegue"
    static let sortFilterSegue = "SortFilterSegue"
    
    // MARK: - Colors
    
    static let cellBackgroundColor = "cellBackgroundColor"
    static let secondaryCellBackgroundColor = "secondaryCellBackgroundColor"
    
    // MARK: - User Defaults
    
    static let currentSortStyle = "currentSortStyle"
    static let currentFilterStyle = "currentFilterStyle"
    static let currentFilterTag = "currentFilterTag"
    static let currentFilterDate = "currentFilterDate"
    static let notificationsAllowed = "notificationsAllowed"
    
    // MARK: - Notifications
    
    static let countdownEndedNotificationTitle = "It's time!"
    static func countdownEndedNotificationBody(for event: Event) -> String {
        return "The countdown for \"\(event.name)\" is over!"
    }
    
    // MARK: - Images
    
    static let sortImageInactive = "arrow.up.arrow.down.square"
    static let sortImageActive = "arrow.up.arrow.down.square.fill"
    static let archiveImageInactive = "archivebox"
    static let archiveImageActive = "archivebox.fill"
    
    // MARK: - Methods
    
    func stripMultiSpace() -> String {
        var string = self
        
        while string.contains("  ") {
            string = string.replacingOccurrences(of: "  ", with: " ")
        }
        while string.last == " " {
            string.removeLast()
        }
        while string.first == " " {
            string.removeFirst()
        }
        
        return string
    }
}

extension Character {
    static let tagSeparator = Character(",")
}
