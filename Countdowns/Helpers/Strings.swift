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
    
    static let emptyTagDisplayText = "(untagged)"
    
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
    static let currentFilter = "currentFilterStyle"
    static let currentFilterTag = "currentFilterTag"
    static let currentFilterDate = "currentFilterDate"
    static let notificationsAllowed = "notificationsAllowed"
    
    // MARK: - Notifications
    
    static let countdownEndedNotificationTitle = "It's time!"
    static func countdownEndedNotificationBody(for event: Event) -> String {
        "The countdown for \"\(event.name)\" is over! It will now be added to the event archive for posterity."
    }
    
    // MARK: - Images
    
    static let sortImageInactive = "arrow.up.arrow.down.square"
    static let sortImageActive = "arrow.up.arrow.down.square.fill"
    static let archiveImageInactive = "archivebox"
    static let archiveImageActive = "archivebox.fill"
}

extension Character {
   static let tagSeparator: Character = ","

   static func +(lhs: Character, rhs: Character) -> String {
      String(lhs) + String(rhs)
   }
}

func +(lhs: Character, rhs: String) -> String {
   String(lhs) + rhs
}

func +(lhs: String, rhs: Character) -> String {
   lhs + String(rhs)
}
