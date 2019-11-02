//
//  DateFormatters.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-22.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import Foundation

extension DateFormatter {
    static var eventDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        
        formatter.timeZone = .autoupdatingCurrent
        formatter.calendar = .autoupdatingCurrent
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        return formatter
    }
    
    /// Returns a nicely formatted string of the time remaining for an event.
    static func formattedTimeRemaining(for event: Event) -> String {
        let formatter = DateComponentsFormatter()
        formatter.calendar = .autoupdatingCurrent
        if event.timeInterval > 604_800 {
            formatter.allowedUnits = [.year, .month, .day]
        } else if event.timeInterval > 86_400 {
            formatter.allowedUnits = [.year, .month, .day, .hour]
        } else if event.timeInterval > 3600 {
            formatter.allowedUnits = [.year, .month, .day, .hour, .minute]
        } else {
            formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        }
        formatter.unitsStyle = .full
        
        formatter.maximumUnitCount = 2
        
        guard let formattedTime = formatter.string(from: event.timeInterval)
            else { return "" }
        
        return formattedTime
    }
}
