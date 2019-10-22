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
    var name: String
    var dateTime: Date
    //var tags: [Tag]
    var note: String = ""
    var imageData: Data?
    var hasTime: Bool
    
    var postEventNote: String?
    var archived: Bool = false
    
    // MARK: - Computed Properties
    
    var eventPassed: Bool {
        return Date() > dateTime
    }

    var timeInterval: TimeInterval {
        return dateTime.timeIntervalSinceNow 
    }
    
    // MARK: - Init
    init(name: String, dateTime: Date, note: String = "", image: UIImage? = nil, hasTime: Bool = false) {
        self.name = name
        self.dateTime = dateTime
        self.note = note
        self.hasTime = hasTime
        if let image = image, let imageData = image.jpegData(compressionQuality: 1.0) {
            self.imageData = imageData
        }
    }
}

// MARK: Extensions

extension Event: Equatable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs === rhs
    }
}
