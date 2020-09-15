//
//  DateFormatters.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-22.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import Foundation

extension DateFormatter {
    static var eventDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        
        formatter.timeZone = .autoupdatingCurrent
        formatter.calendar = .autoupdatingCurrent
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        return formatter
    }()

   static let timeRemainingFormatter = configure(DateComponentsFormatter()) {
      $0.calendar = .autoupdatingCurrent
      $0.unitsStyle = .full
      $0.maximumUnitCount = 2
   }
    
    /// Returns a nicely formatted string of the time remaining for an event.
    static func formattedTimeRemaining(for event: Event) -> String {
        if event.timeRemaining > 604_800 {
            timeRemainingFormatter.allowedUnits = [.year, .month, .day]
        } else if event.timeRemaining > 86_400 {
            timeRemainingFormatter.allowedUnits = [.year, .month, .day, .hour]
        } else if event.timeRemaining > 3600 {
            timeRemainingFormatter.allowedUnits = [.year, .month, .day, .hour, .minute]
        } else {
            timeRemainingFormatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        }
        
        return timeRemainingFormatter.string(from: event.timeRemaining) ?? ""
    }
}
