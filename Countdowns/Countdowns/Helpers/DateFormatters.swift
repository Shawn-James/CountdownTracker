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
    
    static func formattedTimeRemaining(for event: Event) -> String {
        let formatter = DateComponentsFormatter()
        //if event.timeRemaining.duration > 31_536_000 {
        formatter.calendar = .autoupdatingCurrent
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 2
        
        guard let formattedTime = formatter.string(from: event.timeInterval)
            else { return "" }
        
        return formattedTime
    }
}
