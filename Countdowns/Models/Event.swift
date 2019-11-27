//
//  Event.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit

class Event: Codable {
    // MARK: - Properties
    var uuid: String
    var name: String
    var dateTime: Date
    var tags: [Tag]
    var note: String = ""
    var hasTime: Bool
    var creationDate: Date
    var modifiedDate: Date
    
    var didNotifyDone: Bool = false {
        didSet {
            EventController.shared.saveArchivedEventsToPersistenceStore()
        }
    }
    var archived: Bool = false {
        didSet {
            EventController.shared.saveArchivedEventsToPersistenceStore()
        }
    }
    
    // MARK: - Computed Properties
    
    var dateTimeHasPassed: Bool {
        return Date() > dateTime
    }

    /// Time remaining until event date/time in `TimeInterval` format
    var timeInterval: TimeInterval {
        return dateTime.timeIntervalSinceNow 
    }
    
    /// A string representation of the event's complete list of tags
    var tagsText: String {
        var tagsText = ""
        for i in 0 ..< tags.count {
            tagsText += "\(tags[i])"
            if i != tags.count - 1 {
                tagsText += ", "
            }
        }
        return tagsText
    }
    
    // MARK: - Init
    init(name: String, dateTime: Date, tags: [Tag] = [], note: String = "", hasTime: Bool = false) {
        self.name = name
        self.dateTime = dateTime
        self.tags = tags
        self.note = note
        self.hasTime = hasTime
        self.creationDate = Date()
        self.modifiedDate = creationDate
        self.uuid = UUID().uuidString
    }
}

// MARK: - Extensions

extension Event: Equatable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs === rhs
    }
}
